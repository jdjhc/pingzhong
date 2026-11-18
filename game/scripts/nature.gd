class_name Nature
extends RefCounted
## 瓶子里的自然。只有元素和反应，没有“灾害”这种规则——灾是反应连起来的结果。
## 每一格连续地存着：石的高度、水、土里的水、草木、枯、肥、沙、火、灰、雪、藻、朽木。
## 水守恒：格子里的水 + 土里的水 + 雪 + 汽 + 云 = 画进去的总量。

const N := 25
const C := 12
const R := 11.3
const YEAR := 96.0
const DAY := 16.0
const STEP := 0.1

var h := PackedFloat32Array()
var w := PackedFloat32Array()
var moist := PackedFloat32Array()
var veg := PackedFloat32Array()      # 0 光地 · 1 草 · 2 灌 · 3 木
var dry := PackedFloat32Array()      # 枯
var soil := PackedFloat32Array()     # 肥
var sand := PackedFloat32Array()
var fire := PackedFloat32Array()     # 还能烧多久（1 → 0）
var ash := PackedFloat32Array()
var snow := PackedFloat32Array()
var ice := PackedFloat32Array()
var algae := PackedFloat32Array()
var dead := PackedFloat32Array()     # 朽木、炭
var temp := PackedFloat32Array()
var capv := PackedFloat32Array()     # 这一格的土能存多少水
var moved := PackedFloat32Array()    # 这一步流过多少水（判断死水活水）
var inside := PackedByteArray()
var cells := PackedInt32Array()
var edge := PackedInt32Array()
var nb4: Array = []
var nb8: Array = []

var vapor := 0.0        # 汽：瓶壁上的水珠
var cloud := 0.0        # 云
var rain_left := 0.0
var rain_rate := 0.0
var rain_thr := 1.0
var time := 0.0
var base := 13.0        # 这会儿的日有多暖
var cold := 0.0         # 寒有多重（0..1）
var wind := Vector2.ZERO
var deer: Array = []
var wolves: Array = []
var events: Array = []
var forest_n := 0
var grass_n := 0
var water_n := 0
var fuel: PackedInt32Array = []
var rng := RandomNumberGenerator.new()
var _acc := 0.0
var _parity := false
var _arr_t := 0.0
var _deer_wait := 0.0
var _wolf_wait := 0.0
var _uid := 0


func setup(seed_value: int) -> void:
	rng.seed = seed_value
	var noise := FastNoiseLite.new()
	noise.seed = seed_value
	noise.frequency = 0.11
	for a in [h, w, moist, veg, dry, soil, sand, fire, ash, snow, ice, algae, dead, temp, capv, moved]:
		a.resize(N * N)
		a.fill(0.0)
	inside.resize(N * N)
	nb4.resize(N * N)
	nb8.resize(N * N)
	for j in N:
		for i in N:
			var k := j * N + i
			inside[k] = 1 if Vector2(i - C, j - C).length() <= R else 0
	for j in N:
		for i in N:
			var k := j * N + i
			var a4 := PackedInt32Array()
			var a8 := PackedInt32Array()
			if inside[k] == 1:
				cells.append(k)
				for dj in range(-1, 2):
					for di in range(-1, 2):
						if di == 0 and dj == 0:
							continue
						var ii := i + di
						var jj := j + dj
						if ii < 0 or jj < 0 or ii >= N or jj >= N or inside[jj * N + ii] == 0:
							continue
						a8.append(jj * N + ii)
						if di == 0 or dj == 0:
							a4.append(jj * N + ii)
				if a4.size() < 4:
					edge.append(k)
				h[k] = maxf(0.0, noise.get_noise_2d(i, j) + 0.25) * 0.9
				soil[k] = 0.14 + 0.16 * rng.randf()
				capv[k] = 0.003
			nb4[k] = a4
			nb8[k] = a8

func cell_at(x: float, z: float) -> int:
	var i := int(round(x)) + C
	var j := int(round(z)) + C
	if i < 0 or j < 0 or i >= N or j >= N:
		return -1
	var k := j * N + i
	return k if inside[k] == 1 else -1

func cell_pos(k: int) -> Vector2:
	return Vector2(k % N - C, k / N - C)

func total_water() -> float:
	var s := vapor + cloud
	for i in cells:
		s += w[i] + moist[i] + snow[i]
	return s

func season() -> float:      # +1 盛夏 · -1 隆冬
	return sin(TAU * fmod(time / YEAR, 1.0))


# ---------------------------------------------------------------- 造物主的四笔
func add_water(ids: Array, per: float) -> void:
	for i in ids:
		w[i] += per
		fire[i] = 0.0

func plant(i: int) -> bool:
	if w[i] > 0.12 or h[i] > 1.3:
		return false
	veg[i] = maxf(veg[i], 2.6)
	dry[i] = 0.0
	return true

func raise(i: int) -> void:
	h[i] = minf(3.0, h[i] + 2.2)
	veg[i] = 0.0
	for j in nb8[i]:
		h[j] = minf(3.0, h[j] + 0.7)

func erase(ids: Array) -> void:
	for i in ids:
		vapor += w[i] + snow[i]
		w[i] = 0.0
		snow[i] = 0.0
		if veg[i] > 0.0:
			soil[i] = minf(1.0, soil[i] + 0.02)
		veg[i] = 0.0
		dead[i] = 0.0
		fire[i] = 0.0
		h[i] = minf(h[i], 0.15)

func ignite(i: int) -> bool:
	if fire[i] > 0.0 or w[i] > 0.03 or veg[i] < 0.5:
		return false
	fire[i] = 1.0
	events.append({"t": "ignite", "i": i})
	return true


# ---------------------------------------------------------------- 时间
func tick(dt: float) -> void:
	_acc += dt
	while _acc >= STEP:
		_acc -= STEP
		_step(STEP)

func _step(dt: float) -> void:
	time += dt
	var s := season()
	base = 13.0 + 15.0 * s
	cold = maxf(0.0, -s)
	var ang := time * 0.05
	wind = Vector2(cos(ang), sin(ang)) * (0.5 + 0.3 * sin(time * 0.13))
	wind = wind.lerp(Vector2(0, 1.6), cold)      # 寒从瓶子背面压过来
	_parity = not _parity
	_climate()
	_flow(dt)
	_soak(dt)
	_sky(dt)
	_grow(dt)
	_ground(dt)
	_burn(dt)
	_beasts(dt)
	_arrive(dt)

## 日、寒：每一格有多暖。山和林子挡得住寒
func _climate() -> void:
	for i in cells:
		var t := base - 3.0 * h[i]
		if cold > 0.0:
			var sh := false
			for k in range(1, 4):
				var j := i - N * k
				if j < 0 or inside[j] == 0:
					break
				if h[j] > 1.0 or veg[j] > 2.0:
					sh = true
					break
			t -= cold * 7.0 * (0.25 if sh else 1.0)
		temp[i] = t
		ice[i] = 1.0 if (t < 0.0 and w[i] > 0.01) else 0.0

## 水往低处流；冰不流
func _flow(dt: float) -> void:
	moved.fill(0.0)
	var n := cells.size()
	var k := minf(1.0, 5.0 * dt)
	for q in n:
		var i := cells[q] if _parity else cells[n - 1 - q]
		var wi := w[i]
		if wi < 0.004 or ice[i] > 0.5:
			continue
		var si := h[i] + wi
		var best := -1
		var bs := si
		for j in nb4[i]:
			var sj := h[j] + w[j]
			if sj < bs:
				bs = sj
				best = j
		if best >= 0:
			var m := minf(wi, (si - bs) * 0.5) * k
			w[i] -= m
			w[best] += m
			moved[i] += m
			moved[best] += m

## 土 + 水 → 泥；雪 + 日 → 水；水 + 日 → 汽
func _soak(dt: float) -> void:
	water_n = 0
	for i in cells:
		var cap := maxf(0.001, 0.003 + 0.002 * veg[i] - 0.002 * sand[i])
		capv[i] = cap
		if snow[i] > 0.0 and temp[i] > 2.0:
			var m := minf(snow[i], 0.02 * (temp[i] - 2.0) * dt)
			snow[i] -= m
			w[i] += m
		if w[i] > 0.0 and moist[i] < cap:
			var m2 := minf(minf(w[i], cap - moist[i]), 0.1 * dt)
			w[i] -= m2
			moist[i] += m2
		if w[i] > 0.05:
			water_n += 1
			if ice[i] < 0.5:
				for j in nb8[i]:
					if w[j] < 0.02 and moist[j] < capv[j]:
						var m3 := minf(w[i] * 0.2, 0.004 * dt)
						w[i] -= m3
						moist[j] += m3
		elif moist[i] > 0.02:
			for j in nb4[i]:
				if w[j] < 0.02:
					var d := (moist[i] - moist[j]) * 0.08 * dt
					if d > 0.0:
						moist[i] -= d
						moist[j] += d
		if moist[i] > cap:
			w[i] += moist[i] - cap
			moist[i] = cap
		var heat := clampf(temp[i] / 25.0, 0.0, 1.3)
		if w[i] > 0.0 and ice[i] < 0.5:
			var shade := 1.0
			for j in nb4[i]:
				if veg[j] > 2.0:
					shade = 0.5
					break
			var e := minf(w[i], 0.002 * heat * shade * dt)
			w[i] -= e
			vapor += e
		var e2 := moist[i] * 0.07 * heat * heat * (0.6 if veg[i] > 2.0 else 1.0) * dt
		moist[i] -= e2
		vapor += e2

## 汽 → 云 → 雨／雪；云厚了打雷
func _sky(dt: float) -> void:
	var c := vapor * 0.05 * dt
	vapor -= c
	cloud += c
	var dew := vapor * 0.01 * dt          # 没变成云的汽，顺着瓶壁淌回瓶边
	vapor -= dew
	w[edge[rng.randi() % edge.size()]] += dew
	var ff := clampf(float(forest_n) / cells.size() * 5.0, 0.0, 1.0)
	rain_thr = maxf(1.0, total_water() * lerpf(0.35, 0.15, ff))     # 林子招雨：林子越多，云越薄就能下
	if rain_left <= 0.0 and cloud > rain_thr:
		rain_left = 7.0
		rain_rate = cloud * 0.85 / 7.0
		events.append({"t": "rain", "snow": base < 1.0})
	if rain_left > 0.0:
		rain_left -= dt
		var amt := minf(cloud, rain_rate * dt)
		cloud -= amt
		for k in 10:
			var i := cells[rng.randi() % cells.size()]
			for tries in 6:
				if rng.randf() < (0.95 if veg[i] > 2.0 else 0.05 + 0.1 * veg[i]):
					break
				i = cells[rng.randi() % cells.size()]
			if temp[i] < 1.0:
				snow[i] += amt / 10.0
			else:
				w[i] += amt / 10.0
	if cloud > rain_thr * 0.6 and base > 16.0 and fuel.size() > 0:
		if rng.randf() < minf(0.05, 0.004 * fuel.size()) * dt:
			var i2 := fuel[rng.randi() % fuel.size()]
			events.append({"t": "bolt", "i": i2})
			ignite(i2)

## 草 → 灌 → 木；没水就枯；木倒了成朽木，烂回土里；木 + 风 → 种子
func _grow(dt: float) -> void:
	forest_n = 0
	grass_n = 0
	fuel.clear()
	var wn := wind.normalized()
	for i in cells:
		if fire[i] > 0.0:
			continue
		var sat := moist[i] / capv[i]
		var v := veg[i]
		if sat < 0.15 and temp[i] > 14.0:
			dry[i] = minf(1.0, dry[i] + dt / 18.0)
		elif sat > 0.3:
			dry[i] = maxf(0.0, dry[i] - dt / 8.0)
		if w[i] > 0.12 or h[i] > 1.3:
			if v > 0.0:
				var d := minf(v, 0.08 * dt)
				if v > 2.0:
					dead[i] = minf(1.0, dead[i] + d * 0.4)
				v -= d
		elif sat > 0.25 and temp[i] > 4.0 and snow[i] < 0.05:
			var lim := 1.2
			if soil[i] > 0.22:
				lim = 2.0
				if soil[i] < 0.35 and v < 2.0:
					pass                                  # 土不够肥，长不成木
				elif v >= 2.0:
					lim = 3.0          # 只有落了种子的灌才长成木
			if v < lim:
				var rate := 0.045 * sat * (0.5 + soil[i] * 1.5) * (0.2 if v >= 2.0 else 1.0)
				v = minf(lim, v + rate * dt)
			if v > 0.8:
				soil[i] = minf(1.0, soil[i] + 0.0002 * dt)
		if dry[i] >= 1.0 and v > 0.0:
			var d2 := (0.006 if v > 2.0 else 0.02) * dt
			if v > 2.0:
				dead[i] = minf(1.0, dead[i] + d2 * 0.5)
			else:
				soil[i] = minf(1.0, soil[i] + d2 * 0.05)
			v = maxf(0.0, v - d2)
		veg[i] = v
		if v >= 2.4:
			forest_n += 1
			if rng.randf() < dt * 0.006:
				var p := cell_pos(i) + wn * rng.randf_range(1.0, 3.0) + Vector2(rng.randf_range(-1, 1), rng.randf_range(-1, 1))
				var t := cell_at(p.x, p.y)
				if t >= 0 and veg[t] >= 0.8 and veg[t] < 2.0 and soil[t] > 0.35:
					veg[t] = 2.05
		elif v >= 0.6:
			grass_n += 1
		if v > 0.8 and (dry[i] > 0.6 or (v > 2.0 and sat < 0.3)):
			fuel.append(i)
		if dead[i] > 0.0:
			var r := minf(dead[i], 0.01 * (0.3 + sat) * dt)
			dead[i] -= r
			soil[i] = minf(1.0, soil[i] + r * 0.6)
		if ash[i] > 0.0:
			var a := minf(ash[i], 0.008 * dt)
			ash[i] -= a
			soil[i] = minf(1.0, soil[i] + a * 0.3)

## 光着的土 + 风 → 沙；死水 + 日 → 藻；光着的土 + 雨 → 冲瘦
func _ground(dt: float) -> void:
	var ws := wind.length()
	var wn := wind.normalized()
	for i in cells:
		if veg[i] < 0.3 and w[i] < 0.02 and moist[i] / capv[i] < 0.2 and h[i] < 0.8 and snow[i] < 0.05:
			var d := ws * 0.001 * dt
			sand[i] = minf(1.0, sand[i] + d)
			soil[i] = maxf(0.0, soil[i] - d * 0.5)
			if sand[i] > 0.6 and ws > 0.9 and rng.randf() < dt * 0.2:
				var p := cell_pos(i) + wn
				var j := cell_at(p.x, p.y)
				if j >= 0 and h[j] < 0.8 and w[j] < 0.02:
					sand[j] = minf(1.0, sand[j] + 0.08)
					veg[j] = maxf(0.0, veg[j] - 0.08)
		elif veg[i] > 0.8:
			sand[i] = maxf(0.0, sand[i] - 0.01 * dt)
		if w[i] > 0.1:
			if moved[i] < 0.0005 and temp[i] > 14.0 and ice[i] < 0.5:
				algae[i] = minf(1.0, algae[i] + dt * 0.006 * (0.5 + soil[i]) * (0.5 if w[i] > 0.4 else 1.0))
			else:
				algae[i] = maxf(0.0, algae[i] - dt * 0.01)
		else:
			algae[i] = maxf(0.0, algae[i] - dt * 0.05)
		if rain_left > 0.0 and veg[i] < 0.3 and w[i] < 0.02:
			soil[i] = maxf(0.0, soil[i] - 0.004 * dt)

## 火：烧到挨着的干东西；遇风出火星；遇水、雨就灭；烧完留灰和炭
func _burn(dt: float) -> void:
	var ws := wind.length()
	var wn := wind.normalized()
	for i in cells:
		if fire[i] <= 0.0:
			continue
		if w[i] > 0.05 or (rain_left > 0.0 and rng.randf() < dt * 0.4):
			fire[i] = 0.0
			continue
		fire[i] -= dt / 4.0
		for j in nb8[i]:
			_catch(j, dt * 0.9)
		if rng.randf() < dt * 0.15 * ws:
			var p := cell_pos(i) + wn * rng.randf_range(2.0, 3.0)
			var t := cell_at(p.x, p.y)
			if t >= 0 and _catch(t, 1.0):
				events.append({"t": "spark", "from": i, "to": t})
		if fire[i] <= 0.0:
			fire[i] = 0.0
			if veg[i] > 2.0:
				dead[i] = minf(1.0, dead[i] + 0.5)
			ash[i] = 1.0
			soil[i] = minf(1.0, soil[i] + 0.06)
			vapor += moist[i] * 0.5
			moist[i] *= 0.5
			veg[i] = 0.02
			dry[i] = 0.0

func _catch(j: int, p: float) -> bool:
	if fire[j] > 0.0 or ash[j] > 0.5 or w[j] > 0.03 or veg[j] < 0.6:
		return false
	var sat := moist[j] / capv[j]
	var f := (veg[j] / 3.0) * (1.0 - sat) * (0.4 + 0.6 * dry[j])
	if rng.randf() < p * f:
		fire[j] = 1.0
		return true
	return false


# ---------------------------------------------------------------- 生灵
func _blocked(k: int) -> bool:
	return k < 0 or h[k] > 1.3 or (w[k] > 0.35 and ice[k] < 0.5)

func _spawn(list: Array, kind: String, x: float, z: float, age: float) -> void:
	_uid += 1
	list.append({"id": _uid, "kind": kind, "x": x, "z": z, "tx": x, "tz": z, "hun": 0.3, "thi": 0.2,
		"age": age, "rt": 0.0, "cd": 30.0, "hp": 1.0, "goal": "", "run": false})

func _die(list: Array, b: Dictionary, cause: String) -> void:
	list.erase(b)
	var k := cell_at(b["x"], b["z"])
	if k >= 0:
		soil[k] = minf(1.0, soil[k] + 0.08)
	events.append({"t": "die", "kind": b["kind"], "cause": cause, "x": b["x"], "z": b["z"], "id": b["id"], "goal": b["goal"], "thi": b["thi"], "age": b["age"], "veg": (veg[k] if k >= 0 else -1.0), "temp": (temp[k] if k >= 0 else 0.0)})

func _nearest_water(x: float, z: float) -> int:
	var best := -1
	var bd := 1e9
	for i in cells:
		if not _blocked(i) and _near_water(i):      # 去岸边喝，不往深水里走
			var p := cell_pos(i)
			var d := (p.x - x) * (p.x - x) + (p.y - z) * (p.y - z)
			if d < bd:
				bd = d
				best = i
	return best

func _walk(b: Dictionary, sp: float) -> bool:
	var d := Vector2(b["tx"] - b["x"], b["tz"] - b["z"])
	var l := d.length()
	if l < 0.05:
		return true
	var st := d / l * minf(sp, l)
	var k := cell_at(b["x"] + st.x, b["z"] + st.y)
	if _blocked(k) and k != cell_at(b["x"], b["z"]):
		var a := rng.randf() * TAU
		b["tx"] = b["x"] + cos(a) * 2.0
		b["tz"] = b["z"] + sin(a) * 2.0
		b["rt"] = 0.6
		return false
	b["x"] += st.x
	b["z"] += st.y
	return l - sp < 0.25

func _near_water(k: int) -> bool:
	if w[k] > 0.03:
		return true
	for j in nb8[k]:
		if w[j] > 0.03:
			return true
	return false

func _common(list: Array, b: Dictionary, dt: float, hun_s: float, thi_s: float, life: float) -> int:
	b["age"] += dt
	b["hun"] += dt / hun_s
	b["thi"] += dt / thi_s
	b["rt"] -= dt
	b["cd"] -= dt
	var k := cell_at(b["x"], b["z"])
	var cause := ""
	if k < 0:
		cause = "lost"
	elif b["hun"] >= 1.0:
		cause = "hunger"
	elif b["thi"] >= 1.0:
		cause = "thirst"
	elif fire[k] > 0.0:
		cause = "fire"
	elif w[k] > 0.5 and ice[k] < 0.5:
		cause = "drown"
	elif b["age"] > life:
		cause = "old"
	elif temp[k] < -3.0 and veg[k] < 2.0:
		b["hp"] -= dt / 25.0
		if b["hp"] <= 0.0:
			cause = "cold"
	else:
		b["hp"] = minf(1.0, b["hp"] + dt / 40.0)
	if cause != "":
		_die(list, b, cause)
		return -1
	return k

func _beasts(dt: float) -> void:
	for b in deer.duplicate():
		var k := _common(deer, b, dt, 40.0, 40.0, YEAR * 4.0)
		if k < 0:
			continue
		if b["rt"] <= 0.0:
			b["rt"] = 1.0
			_deer_think(b, k)
		var there := _walk(b, (2.0 if b["run"] else 1.2) * dt)
		if there:
			if b["goal"] == "eat" and veg[k] > 0.5:
				veg[k] -= minf(0.35, veg[k] - 0.2)
				b["hun"] = maxf(0.0, b["hun"] - 0.3)
				soil[k] = minf(1.0, soil[k] + 0.006)      # 粪
				b["goal"] = ""
				b["rt"] = 0.5
			elif b["goal"] == "drink" and _near_water(k):
				b["thi"] = 0.0
				b["goal"] = ""
				b["rt"] = 0.3
		if b["hun"] < 0.25 and b["thi"] < 0.5 and b["age"] > 40.0 and b["cd"] <= 0.0:
			b["cd"] = 70.0
			_spawn(deer, "deer", b["x"], b["z"], 0.0)
			events.append({"t": "born", "kind": "deer"})
	for b in wolves.duplicate():
		var k := _common(wolves, b, dt, 80.0, 50.0, YEAR * 5.0)
		if k < 0:
			continue
		var prey: Dictionary = {}
		if b["hun"] > 0.3 and b["thi"] < 0.7:
			var bd := 64.0
			for d in deer:
				var dd: float = (d["x"] - b["x"]) * (d["x"] - b["x"]) + (d["z"] - b["z"]) * (d["z"] - b["z"])
				if dd < bd:
					bd = dd
					prey = d
			if not prey.is_empty():
				b["tx"] = prey["x"]
				b["tz"] = prey["z"]
				b["goal"] = "hunt"
				if bd < 0.25:
					_die(deer, prey, "wolf")
					b["hun"] = 0.0
					b["rt"] = 2.0
		if prey.is_empty() and b["rt"] <= 0.0:
			b["rt"] = 1.5
			if b["thi"] > 0.6:
				var wi := _nearest_water(b["x"], b["z"])
				if wi >= 0:
					b["tx"] = cell_pos(wi).x
					b["tz"] = cell_pos(wi).y
					b["goal"] = "drink"
			else:
				var a := rng.randf() * TAU
				b["tx"] = b["x"] + cos(a) * 3.0
				b["tz"] = b["z"] + sin(a) * 3.0
				b["goal"] = ""
		b["run"] = not prey.is_empty()
		_walk(b, (1.9 if b["run"] else 1.0) * dt)
		if b["goal"] == "drink" and _near_water(k):
			b["thi"] = 0.0
			b["goal"] = ""
		if b["hun"] < 0.3 and b["age"] > 40.0 and b["cd"] <= 0.0 and wolves.size() < maxi(2, deer.size() / 5):
			b["cd"] = 70.0
			_spawn(wolves, "wolf", b["x"], b["z"], 0.0)
			events.append({"t": "born", "kind": "wolf"})

func _deer_think(b: Dictionary, k: int) -> void:
	b["run"] = false
	for wf in wolves:
		var d := Vector2(b["x"] - wf["x"], b["z"] - wf["z"])
		if d.length() < 4.0:
			var away := d.normalized() * 3.0
			b["tx"] = b["x"] + away.x
			b["tz"] = b["z"] + away.y
			b["goal"] = ""
			b["run"] = true
			b["rt"] = 0.5
			return
	if b["thi"] > 0.5:
		var wi := _nearest_water(b["x"], b["z"])
		if wi >= 0:
			b["tx"] = cell_pos(wi).x
			b["tz"] = cell_pos(wi).y
			b["goal"] = "drink"
			return
	var p0 := Vector2(b["x"], b["z"])
	if b["hun"] > 0.2:
		var best := -1
		var bs := 0.0
		var ci := k % N
		var cj := k / N
		for dj in range(-4, 5):
			for di in range(-4, 5):
				var ii := ci + di
				var jj := cj + dj
				if ii < 0 or jj < 0 or ii >= N or jj >= N:
					continue
				var q := jj * N + ii
				if inside[q] == 0 or veg[q] < 0.6 or _blocked(q):
					continue
				var sc := (veg[q] if veg[q] <= 2.0 else 1.0) - 0.18 * Vector2(di, dj).length() + rng.randf() * 0.2
				if sc > bs:
					bs = sc
					best = q
		if best >= 0:
			b["tx"] = cell_pos(best).x
			b["tz"] = cell_pos(best).y
			b["goal"] = "eat"
			return
	var a := rng.randf() * TAU
	b["tx"] = p0.x + cos(a) * 3.0
	b["tz"] = p0.y + sin(a) * 3.0
	b["goal"] = ""

## 草够了鹿自己来；鹿够了、有林子藏，狼自己来
func _arrive(dt: float) -> void:
	_arr_t += dt
	if _arr_t < 5.0:
		return
	_arr_t = 0.0
	if deer.is_empty() and grass_n >= 20 and water_n >= 3:
		_deer_wait += 5.0
		if _deer_wait >= 20.0:
			_deer_wait = 0.0
			_come(deer, "deer", 3, 0.6, 2.0)
	else:
		_deer_wait = 0.0
	if wolves.is_empty() and deer.size() >= 10 and forest_n >= 6:
		_wolf_wait += 5.0
		if _wolf_wait >= 30.0:
			_wolf_wait = 0.0
			_come(wolves, "wolf", 2, 2.4, 3.1)
	else:
		_wolf_wait = 0.0

func _come(list: Array, kind: String, count: int, v0: float, v1: float) -> void:
	var opts: Array = []
	for i in cells:
		if veg[i] >= v0 and veg[i] <= v1 and not _blocked(i):
			opts.append(i)
	if opts.is_empty():
		return
	var p := cell_pos(opts[rng.randi() % opts.size()])
	for k in count:
		_spawn(list, kind, p.x + rng.randf_range(-0.4, 0.4), p.y + rng.randf_range(-0.4, 0.4), 30.0 + rng.randf() * 40.0)
	events.append({"t": "arrive", "kind": kind, "x": p.x, "z": p.y})
