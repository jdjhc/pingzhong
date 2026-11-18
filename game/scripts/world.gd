extends Node3D
## 桌上一只瓶子。这里管它长什么样，和你在瓶底画的那一笔；规则全在 Nature 里。
## 屏幕上没有界面：水多水少看水面和瓶壁的水珠，冷热看灯和霜，四种笔画印在桌上那张卡上。

const HS := 1.3
const N := Nature.N
const C := Nature.C

var n: Nature
var cam: Camera3D
var env: Environment
var lamp: MeshInstance3D
var halo: Sprite3D
var floor_mat: ShaderMaterial
var tree_mat: ShaderMaterial
var glass_mat: ShaderMaterial
var table_mat: ShaderMaterial
var da := PackedFloat32Array()
var db := PackedFloat32Array()
var dc := PackedFloat32Array()
var ta: ImageTexture
var tb: ImageTexture
var tc: ImageTexture
var rim: Array = []
var mm: MultiMesh
var jit := PackedVector2Array()
var sprites := {}
var tex_deer: Texture2D
var tex_wolf: Texture2D
var rain: CPUParticles3D
var snowp: CPUParticles3D
var fires: Array = []
var clouds: Array = []
var poofs: Array = []
var poof_i := 0
var bolt: MeshInstance3D
var bolt_t := 0.0
var flash := 0.0
var ink: MeshInstance3D
var ink_mat: StandardMaterial3D
var ink_fade := 0.0
var s_pts := PackedVector2Array()
var drawing := false
var speed := 1.0
var ev_i := 0
var t := 0.0
var light := Color(1, 1, 1)
var auto := false
var shot_dir := ""
var frame := 0
var chips: Array = []
var web: Shelf
var cam_p := Vector3(0, 22, 25)
var cam_l := Vector3(0, 3, 0)
var cam_from_p := Vector3.ZERO
var cam_from_l := Vector3.ZERO
var cam_to_p := Vector3.ZERO
var cam_to_l := Vector3.ZERO
var web_on := false
var web_drag := false
var speed_was := 1.0
var leaves: CPUParticles3D
var petals: CPUParticles3D


func _ready() -> void:
	shot_dir = OS.get_environment("PINGZHONG_SHOT")
	auto = shot_dir != ""
	n = Nature.new()
	n.setup(20261117 if auto else int(Time.get_unix_time_from_system()))
	_build()
	if auto:
		_shot_script()


# ---------------------------------------------------------------- 搭
func _shader(path: String) -> ShaderMaterial:
	var m := ShaderMaterial.new()
	m.shader = load(path)
	return m

func _flat(col: Color, alpha := false) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.albedo_color = col
	if alpha:
		m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	return m

func _build() -> void:
	var we := WorldEnvironment.new()
	env = Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.07, 0.05, 0.04)
	env.glow_enabled = true
	env.glow_intensity = 0.6
	env.glow_bloom = 0.1
	we.environment = env
	add_child(we)

	cam = Camera3D.new()
	cam.fov = 46.0
	add_child(cam)
	cam.look_at_from_position(Vector3(0, 22, 25), Vector3(0, 3, 0))

	var table := MeshInstance3D.new()
	var pm := PlaneMesh.new()
	pm.size = Vector2(160, 160)
	table.mesh = pm
	table.position.y = -0.06
	table_mat = _shader("res://shaders/table.gdshader")
	table.material_override = table_mat
	add_child(table)

	# 瓶底
	for a in [da, db, dc]:
		a.resize(N * N * 4)
		a.fill(0.0)
	ta = ImageTexture.create_from_image(Image.create_from_data(N, N, false, Image.FORMAT_RGBAF, da.to_byte_array()))
	tb = ImageTexture.create_from_image(Image.create_from_data(N, N, false, Image.FORMAT_RGBAF, db.to_byte_array()))
	tc = ImageTexture.create_from_image(Image.create_from_data(N, N, false, Image.FORMAT_RGBAF, dc.to_byte_array()))
	for k in N * N:
		if n.inside[k] == 0:
			var best := -1
			var bd := 1e9
			for q in n.cells:
				var d := Vector2(k % N - q % N, k / N - q / N).length_squared()
				if d < bd:
					bd = d
					best = q
			if bd <= 8.0:
				rim.append(Vector2i(k, best))
	var fl := MeshInstance3D.new()
	var fm := PlaneMesh.new()
	fm.size = Vector2(N, N)
	fm.subdivide_width = 120
	fm.subdivide_depth = 120
	fl.mesh = fm
	fl.extra_cull_margin = 8.0
	floor_mat = _shader("res://shaders/floor.gdshader")
	floor_mat.set_shader_parameter("ta", ta)
	floor_mat.set_shader_parameter("tb", tb)
	floor_mat.set_shader_parameter("tc", tc)
	floor_mat.set_shader_parameter("hs", HS)
	fl.material_override = floor_mat
	add_child(fl)

	# 草木
	mm = MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.use_custom_data = true
	var qm := QuadMesh.new()
	qm.size = Vector2(1, 1)
	mm.mesh = qm
	mm.instance_count = N * N * 2
	var rng := RandomNumberGenerator.new()
	rng.seed = 5
	for k in N * N * 2:
		jit.append(Vector2(rng.randf_range(-0.36, 0.36), rng.randf_range(-0.36, 0.36)))
		mm.set_instance_transform(k, Transform3D(Basis().scaled(Vector3.ZERO), Vector3.ZERO))
		mm.set_instance_custom_data(k, Color(rng.randi() % 2, 0, rng.randf(), 0))
	var mi := MultiMeshInstance3D.new()
	mi.multimesh = mm
	mi.custom_aabb = AABB(Vector3(-13, -1, -13), Vector3(26, 12, 26))
	tree_mat = _shader("res://shaders/tree.gdshader")
	tree_mat.set_shader_parameter("atlas", Art.tex(Art.TREES, 1.0))
	mi.material_override = tree_mat
	add_child(mi)

	tex_deer = Art.tex(Art.DEER, 1.5)
	tex_wolf = Art.tex(Art.WOLF, 1.5)

	# 瓶子
	var prof := [Vector2(11.9, 0), Vector2(11.9, 6.0), Vector2(11.4, 7.8), Vector2(9.5, 9.4), Vector2(6.8, 10.4),
		Vector2(5.2, 11.0), Vector2(4.8, 12.4), Vector2(5.3, 12.7)]
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var seg := 72
	for k in seg:
		var a0 := TAU * k / seg
		var a1 := TAU * (k + 1) / seg
		for p in prof.size() - 1:
			var p0: Vector2 = prof[p]
			var p1: Vector2 = prof[p + 1]
			var tg := (p1 - p0).normalized()
			var nr := Vector2(tg.y, -tg.x)
			var quad := [[a0, p0], [a1, p0], [a1, p1], [a0, p0], [a1, p1], [a0, p1]]
			for v in quad:
				var ang: float = v[0]
				var pp: Vector2 = v[1]
				st.set_normal(Vector3(cos(ang) * nr.x, nr.y, sin(ang) * nr.x))
				st.add_vertex(Vector3(cos(ang) * pp.x, pp.y, sin(ang) * pp.x))
	var glass := MeshInstance3D.new()
	glass.mesh = st.commit()
	glass_mat = _shader("res://shaders/glass.gdshader")
	glass.material_override = glass_mat
	add_child(glass)
	var cork := MeshInstance3D.new()
	var cm := CylinderMesh.new()
	cm.top_radius = 5.0
	cm.bottom_radius = 4.6
	cm.height = 1.8
	cork.mesh = cm
	cork.position.y = 12.9
	cork.material_override = _flat(Color(0.5, 0.35, 0.22))
	add_child(cork)

	# 灯
	lamp = MeshInstance3D.new()
	var sm := SphereMesh.new()
	sm.radius = 1.3
	sm.height = 2.6
	lamp.mesh = sm
	var lm := _flat(Color(1, 0.86, 0.55))
	lm.emission_enabled = true
	lm.emission = Color(1, 0.8, 0.45)
	lm.emission_energy_multiplier = 2.5
	lamp.material_override = lm
	add_child(lamp)
	halo = Sprite3D.new()
	halo.texture = Art.blob(Color(1, 0.8, 0.45, 0.5))
	halo.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	halo.shaded = false
	halo.pixel_size = 0.09
	lamp.add_child(halo)

	# 云
	for k in 7:
		var c := Sprite3D.new()
		c.texture = Art.blob(Color(0.87, 0.82, 0.74, 0.8))
		c.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		c.shaded = false
		c.pixel_size = 0.05
		c.position = Vector3(cos(k * 2.4) * (2.0 + k * 0.6), 8.8 + (k % 3) * 0.4, -6.0 + sin(k * 2.4) * 1.5)
		c.modulate.a = 0.0
		add_child(c)
		clouds.append(c)

	# 雨、雪
	rain = _fall(Color(0.87, 0.82, 0.7, 0.7), Vector2(0.05, 0.6), 26.0, 320)
	snowp = _fall(Color(1, 1, 1, 0.9), Vector2(0.14, 0.14), 5.0, 260)

	# 火
	var ramp := Gradient.new()
	ramp.set_color(0, Color(1, 0.9, 0.4, 1))
	ramp.set_color(1, Color(0.6, 0.1, 0.02, 0))
	ramp.add_point(0.4, Color(1, 0.45, 0.1, 0.9))
	for k in 16:
		var f := CPUParticles3D.new()
		f.amount = 16
		f.lifetime = 0.7
		f.emitting = false
		var q := QuadMesh.new()
		q.size = Vector2(0.45, 0.45)
		var fmat := _flat(Color(1, 1, 1), true)
		fmat.vertex_color_use_as_albedo = true
		fmat.billboard_mode = BaseMaterial3D.BILLBOARD_PARTICLES
		fmat.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
		q.material = fmat
		f.mesh = q
		f.direction = Vector3.UP
		f.spread = 18.0
		f.gravity = Vector3(0, 3, 0)
		f.initial_velocity_min = 1.5
		f.initial_velocity_max = 3.0
		f.emission_shape = CPUParticles3D.EMISSION_SHAPE_SPHERE
		f.emission_sphere_radius = 0.4
		f.color_ramp = ramp
		add_child(f)
		fires.append(f)

	# 一笔落下去的那一下
	for k in 6:
		var p := CPUParticles3D.new()
		p.amount = 22
		p.lifetime = 0.6
		p.one_shot = true
		p.explosiveness = 0.95
		p.emitting = false
		var q2 := QuadMesh.new()
		q2.size = Vector2(0.22, 0.22)
		var pmat := _flat(Color(1, 1, 1), true)
		pmat.vertex_color_use_as_albedo = true
		pmat.billboard_mode = BaseMaterial3D.BILLBOARD_PARTICLES
		q2.material = pmat
		p.mesh = q2
		p.direction = Vector3.UP
		p.spread = 70.0
		p.gravity = Vector3(0, -9, 0)
		p.initial_velocity_min = 2.0
		p.initial_velocity_max = 5.0
		add_child(p)
		poofs.append(p)

	bolt = MeshInstance3D.new()
	bolt.mesh = ImmediateMesh.new()
	var bm := _flat(Color(1, 0.97, 0.85))
	bm.emission_enabled = true
	bm.emission = Color(1, 0.95, 0.8)
	bm.emission_energy_multiplier = 4.0
	bolt.material_override = bm
	add_child(bolt)

	ink = MeshInstance3D.new()
	ink.mesh = ImmediateMesh.new()
	ink_mat = _flat(Color(0.94, 0.89, 0.77), true)
	ink_mat.no_depth_test = true
	ink_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	ink.material_override = ink_mat
	add_child(ink)

	# 桌上的卡
	var card := MeshInstance3D.new()
	var cq := QuadMesh.new()
	cq.size = Vector2(7.2, 4.37)
	card.mesh = cq
	var cmat := _flat(Color(1, 1, 1))
	cmat.albedo_texture = Art.tex(Art.CARD, 2.0)
	card.material_override = cmat
	card.position = Vector3(-13.6, 1.3, 10.2)
	card.rotation_degrees = Vector3(-52, 18, 0)
	add_child(card)

	# 桌上四块小牌：停、一倍、两倍、问号
	var marks := ["pause", "play", "fast", "help"]
	for k in 4:
		var ch := MeshInstance3D.new()
		var q3 := QuadMesh.new()
		q3.size = Vector2(1.9, 1.9)
		ch.mesh = q3
		var m3 := _flat(Color(1, 1, 1))
		m3.albedo_texture = Art.tex(Art.chip(marks[k]), 2.0)
		ch.material_override = m3
		ch.position = Vector3(9.4 + k * 2.3, 0.9, 11.6)
		ch.rotation_degrees = Vector3(-52, -14, 0)
		add_child(ch)
		chips.append(ch)
	web = Shelf.new()
	web.position = Vector3(46, 0, 0)
	add_child(web)
	web.setup(cam, table_mat)
	leaves = _fall(Color(0.85, 0.5, 0.18, 0.95), Vector2(0.17, 0.12), 2.2, 50)
	petals = _fall(Color(0.96, 0.78, 0.78, 0.95), Vector2(0.12, 0.12), 1.8, 40)
	_show_speed()

func set_speed(v: float) -> void:
	if web_on:
		toggle_web()
	speed = v
	_show_speed()

func toggle_web() -> void:
	web_on = not web_on
	if web_on:
		speed_was = speed
		speed = 0.0
		drawing = false
	else:
		speed = speed_was
	web.active = web_on
	web.focus = ""
	web.playing = Shelf.RX
	cam_from_p = cam_p                     # 镜头沿着桌面移过去，不换地方
	cam_from_l = cam_l
	cam_to_p = web.position + Shelf.CAM_POS if web_on else Vector3(0, 22, 25)
	cam_to_l = web.position + Shelf.CAM_LOOK if web_on else Vector3(0, 3, 0)
	var tw := create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.tween_method(_cam_mix, 0.0, 1.0, 0.9)
	_show_speed()

func _cam_mix(u: float) -> void:
	cam_p = cam_from_p.lerp(cam_to_p, u)
	cam_l = cam_from_l.lerp(cam_to_l, u)
	cam.look_at_from_position(cam_p, cam_l)

func _show_speed() -> void:
	var on := [speed == 0.0 and not web_on, speed == 1.0, speed == 2.0, web_on]
	for k in chips.size():
		var ch: MeshInstance3D = chips[k]
		(ch.material_override as StandardMaterial3D).albedo_color = Color(1, 1, 1) if on[k] else Color(0.5, 0.45, 0.4)
		ch.position.y = 1.25 if on[k] else 0.9

func _chip_hit(sp: Vector2) -> bool:
	if web_on:
		if cam.unproject_position(web.close_chip.global_position).distance_to(sp) < 60.0:
			toggle_web()
			return true
		return false
	for k in chips.size():
		if cam.unproject_position(chips[k].global_position).distance_to(sp) < 48.0:
			match k:
				0: set_speed(0.0)
				1: set_speed(1.0)
				2: set_speed(2.0)
				3: toggle_web()
			return true
	return false

func _fall(col: Color, size: Vector2, vel: float, amount: int) -> CPUParticles3D:
	var p := CPUParticles3D.new()
	p.amount = amount
	p.lifetime = 9.0 / vel
	p.emitting = false
	var q := QuadMesh.new()
	q.size = size
	var m := _flat(col, true)
	m.billboard_mode = BaseMaterial3D.BILLBOARD_FIXED_Y
	q.material = m
	p.mesh = q
	p.position = Vector3(0, 9.0, 0)
	p.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
	p.emission_box_extents = Vector3(8.0, 0.3, 8.0)
	p.direction = Vector3.DOWN
	p.spread = 3.0
	p.gravity = Vector3.ZERO
	p.initial_velocity_min = vel
	p.initial_velocity_max = vel * 1.2
	add_child(p)
	return p


# ---------------------------------------------------------------- 每一帧
func _process(dt: float) -> void:
	t += dt
	frame += 1
	n.tick(dt * speed)
	while ev_i < n.events.size():
		_on_event(n.events[ev_i])
		ev_i += 1
	_sky(dt)
	_sync(dt)
	if frame % 2 == 0:
		_trees()
	_beasts(dt)
	_fires()
	_ink(dt)

func _sky(dt: float) -> void:
	var now := n.time + n._acc                 # 规则是一格一格走的，灯要跟着连续的时间走才不顿
	var yp := fmod(now / Nature.YEAR, 1.0)
	var s := sin(TAU * yp)
	var co := cos(TAU * yp)
	var four := Vector4(maxf(0.0, co), maxf(0.0, s), maxf(0.0, -co), maxf(0.0, -s))      # 春 夏 秋 冬
	var a := TAU * fmod(now / Nature.DAY, 1.0)
	var rad := lerpf(27.0, 19.0, (s + 1.0) * 0.5)          # 灯近是夏，灯远是冬
	lamp.position = Vector3(cos(a) * rad, sin(a) * rad * 0.8 + 3.0, -7.0)
	var dayf := smoothstep(-3.0, 6.0, lamp.position.y)
	var warm := Color(1.0, 0.96, 0.88).lerp(Color(0.86, 0.92, 1.0), n.cold)
	light = Color(0.66, 0.7, 0.84).lerp(warm, dayf)
	flash = maxf(0.0, flash - dt * 4.0)
	var lv := Vector3(light.r, light.g, light.b) * (1.0 + flash)
	floor_mat.set_shader_parameter("light", lv)
	floor_mat.set_shader_parameter("t", t)
	tree_mat.set_shader_parameter("light", lv)
	web.light = lv
	tree_mat.set_shader_parameter("t", t)
	tree_mat.set_shader_parameter("wind", n.wind.length())
	tree_mat.set_shader_parameter("yp", yp)
	floor_mat.set_shader_parameter("season", four)
	leaves.emitting = four.z > 0.45 and n.forest_n > 2 and speed > 0.0
	petals.emitting = four.x > 0.55 and n.forest_n > 2 and speed > 0.0
	table_mat.set_shader_parameter("light", Vector3(light.r, light.g, light.b))
	var tot := maxf(1.0, n.total_water())
	glass_mat.set_shader_parameter("t", t)
	glass_mat.set_shader_parameter("vapor", clampf(n.vapor / tot * 0.9, 0.0, 0.5))
	glass_mat.set_shader_parameter("fog", clampf(n.cloud / n.rain_thr, 0.0, 1.0) * 0.6)
	glass_mat.set_shader_parameter("frost", n.cold)
	var burning := 0
	for i in n.cells:
		if n.fire[i] > 0.0:
			burning += 1
	glass_mat.set_shader_parameter("smoke", clampf(burning / 12.0, 0.0, 1.0))
	var ca := clampf(n.cloud / n.rain_thr, 0.0, 1.0)
	for k in clouds.size():
		var c: Sprite3D = clouds[k]
		var on := clampf(ca * clouds.size() - k, 0.0, 1.0)
		c.modulate = Color(1, 1, 1, 1).lerp(Color(0.5, 0.5, 0.55, 1), ca * 0.6) * Color(light.r, light.g, light.b, on * 0.85)
		c.position.x += sin(t * 0.3 + k) * dt * 0.2
	rain.emitting = n.rain_left > 0.0 and n.base >= 1.0
	snowp.emitting = n.rain_left > 0.0 and n.base < 1.0
	if bolt_t > 0.0:
		bolt_t -= dt
		if bolt_t <= 0.0:
			(bolt.mesh as ImmediateMesh).clear_surfaces()

func _sync(dt: float) -> void:
	var k := 1.0 - exp(-dt * 6.0)
	for i in n.cells:
		var o := i * 4
		da[o] = lerpf(da[o], n.h[i], k)
		da[o + 1] = lerpf(da[o + 1], n.w[i], k)
		da[o + 2] = lerpf(da[o + 2], n.veg[i], k)
		da[o + 3] = lerpf(da[o + 3], n.moist[i] / n.capv[i], k)
		db[o] = lerpf(db[o], 1.0 if n.fire[i] > 0.0 else 0.0, k * 2.0)
		var white := 1.0 if n.ice[i] > 0.5 else clampf(n.snow[i] * 40.0 + clampf(-n.temp[i] / 12.0, 0.0, 0.35), 0.0, 1.0)
		db[o + 1] = lerpf(db[o + 1], white, k)
		db[o + 2] = lerpf(db[o + 2], n.ash[i], k)
		db[o + 3] = lerpf(db[o + 3], n.soil[i], k)
		dc[o] = lerpf(dc[o], n.sand[i], k)
		dc[o + 1] = lerpf(dc[o + 1], n.dry[i], k)
		dc[o + 2] = lerpf(dc[o + 2], n.algae[i], k)
		dc[o + 3] = lerpf(dc[o + 3], n.dead[i], k)
	for pr in rim:
		var o2: int = pr.x * 4
		var o3: int = pr.y * 4
		for q in 4:
			da[o2 + q] = da[o3 + q]
			db[o2 + q] = db[o3 + q]
			dc[o2 + q] = dc[o3 + q]
	ta.update(Image.create_from_data(N, N, false, Image.FORMAT_RGBAF, da.to_byte_array()))
	tb.update(Image.create_from_data(N, N, false, Image.FORMAT_RGBAF, db.to_byte_array()))
	tc.update(Image.create_from_data(N, N, false, Image.FORMAT_RGBAF, dc.to_byte_array()))

func _trees() -> void:
	var zero := Transform3D(Basis().scaled(Vector3.ZERO), Vector3.ZERO)
	for i in n.cells:
		var v := da[i * 4 + 2]
		var y := da[i * 4] * HS
		var x := float(i % N - C)
		var z := float(i / N - C)
		var burning := 1.0 if n.fire[i] > 0.0 else 0.0
		var charred := dc[i * 4 + 3] > 0.25 and v < 1.0
		for s in 2:
			var k := i * 2 + s
			var cd := mm.get_instance_custom_data(k)
			var hgt := 0.0
			var kind := 0.0
			if s == 0:
				if v >= 2.4:                     # 木
					hgt = 1.4 + 2.5 * (v - 2.4) + cd.b * 0.4
					kind = float(int(cd.b * 97.0) % 2)
				elif v >= 2.0:                   # 树苗
					hgt = 0.9 + 1.2 * (v - 2.0)
					kind = 4.0
				elif v > 1.3:                    # 灌
					hgt = 0.45 + 0.75 * (v - 1.3)
					kind = 2.0
				elif charred:                    # 炭桩
					hgt = 1.6
					kind = 3.0
			elif v > 2.7:
				hgt = 1.2 + 2.0 * (v - 2.7) + cd.b * 0.4
				kind = float(int(cd.b * 61.0) % 2)
			if hgt > 0.0:
				var j: Vector2 = jit[k]
				mm.set_instance_transform(k, Transform3D(Basis().scaled(Vector3(hgt * 0.67, hgt, 1)), Vector3(x + j.x, y, z + j.y)))
				mm.set_instance_custom_data(k, Color(kind, burning, cd.b, 0))
			else:
				mm.set_instance_transform(k, zero)

func _beasts(dt: float) -> void:
	var seen := {}
	for list in [n.deer, n.wolves]:
		for b in list:
			var id: int = b["id"]
			seen[id] = true
			var sp: Sprite3D = sprites.get(id)
			var k := n.cell_at(b["x"], b["z"])
			var y := (da[k * 4] * HS) if k >= 0 else 0.0
			var target := Vector3(b["x"], y, b["z"])
			if sp == null:
				sp = Sprite3D.new()
				sp.texture = tex_deer if b["kind"] == "deer" else tex_wolf
				sp.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y
				sp.shaded = false
				sp.alpha_cut = SpriteBase3D.ALPHA_CUT_DISCARD
				sp.pixel_size = 0.016 if b["kind"] == "deer" else 0.0145
				sp.offset = Vector2(0, 58)
				sp.position = target
				sp.scale = Vector3.ONE * 0.01
				add_child(sp)
				sprites[id] = sp
			var mv := target - sp.position
			if absf(mv.x) > 0.01:
				sp.flip_h = mv.x < 0.0
			sp.position = sp.position.lerp(target, minf(1.0, dt * 8.0))
			var moving := Vector2(b["tx"] - b["x"], b["tz"] - b["z"]).length() > 0.2
			sp.position.y = y + (absf(sin(t * (12.0 if b["run"] else 8.0) + id)) * 0.14 if moving else 0.0)
			var grown := 0.6 + 0.4 * clampf(b["age"] / 40.0, 0.0, 1.0)
			sp.scale = sp.scale.lerp(Vector3.ONE * grown, minf(1.0, dt * 5.0))
			sp.modulate = Color(light.r, light.g, light.b)
	for id in sprites.keys():
		if not seen.has(id):
			var sp2: Sprite3D = sprites[id]
			sprites.erase(id)
			var tw := create_tween()
			tw.tween_property(sp2, "scale", Vector3(1.2, 0.05, 1.2), 0.35)
			tw.tween_callback(sp2.queue_free)

func _fires() -> void:
	var k := 0
	for i in n.cells:
		if n.fire[i] > 0.0 and k < fires.size():
			var f: CPUParticles3D = fires[k]
			f.position = Vector3(i % N - C, da[i * 4] * HS + 0.4, i / N - C)
			f.emitting = true
			k += 1
	while k < fires.size():
		fires[k].emitting = false
		k += 1

func _on_event(ev: Dictionary) -> void:
	match ev["t"]:
		"bolt":
			var i: int = ev["i"]
			var p := Vector3(i % N - C, n.h[i] * HS, i / N - C)
			var im := bolt.mesh as ImmediateMesh
			im.clear_surfaces()
			im.surface_begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)
			var top := Vector3(p.x * 0.3, 9.5, p.z * 0.3)
			for q in 9:
				var u := q / 8.0
				var c := top.lerp(p, u) + Vector3(sin(q * 2.7) * 0.6, 0, cos(q * 1.9) * 0.6) * (1.0 - u) * (0.0 if q == 0 else 1.0)
				im.surface_add_vertex(c + Vector3(-0.09, 0, 0))
				im.surface_add_vertex(c + Vector3(0.09, 0, 0))
			im.surface_end()
			bolt_t = 0.18
			flash = 1.2
		"arrive":
			poof(Vector3(ev["x"], 0.5, ev["z"]), Color(0.81, 0.44, 0.24) if ev["kind"] == "deer" else Color(0.87, 0.78, 0.62))
		"die":
			poof(Vector3(ev["x"], 0.5, ev["z"]), Color(0.87, 0.78, 0.62))

func poof(p: Vector3, col: Color) -> void:
	var e: CPUParticles3D = poofs[poof_i % poofs.size()]
	poof_i += 1
	e.position = p
	e.color = col
	e.restart()
	e.emitting = true


# ---------------------------------------------------------------- 画
func to_floor(sp: Vector2) -> Vector3:
	var o := cam.project_ray_origin(sp)
	var d := cam.project_ray_normal(sp)
	if absf(d.y) < 0.001:
		return Vector3(999, 0, 999)
	return o + d * (-o.y / d.y)

func _unhandled_input(ev: InputEvent) -> void:
	if auto:
		return
	if ev is InputEventKey and ev.pressed and not ev.echo:
		match ev.keycode:
			KEY_SPACE: set_speed(1.0 if speed == 0.0 else 0.0)
			KEY_1: set_speed(1.0)
			KEY_2: set_speed(2.0)
			KEY_H, KEY_SLASH: toggle_web()
			KEY_ESCAPE:
				if web_on:
					toggle_web()
		return
	if ev is InputEventMouseButton and ev.button_index == MOUSE_BUTTON_LEFT:
		if ev.pressed:
			if _chip_hit(ev.position):
				return
			if web_on:
				return
			drawing = true
			ink_fade = 0.0
			s_pts = PackedVector2Array([ev.position])
		else:
			if drawing:
				drawing = false
				finish(s_pts)
	elif ev is InputEventMouseMotion:
		if web_on:
			web.hover(ev.position)
		elif drawing and ev.position.distance_to(s_pts[s_pts.size() - 1]) > 4.0:
			s_pts.append(ev.position)

func _ink(dt: float) -> void:
	var im := ink.mesh as ImmediateMesh
	im.clear_surfaces()
	if not drawing:
		ink_fade -= dt * 3.0
		if ink_fade <= 0.0:
			return
	ink_mat.albedo_color.a = 1.0 if drawing else clampf(ink_fade, 0.0, 1.0)
	if s_pts.size() < 2:
		return
	im.surface_begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)
	var prev := to_floor(s_pts[0])
	for k in s_pts.size():
		var p := to_floor(s_pts[k])
		var c := n.cell_at(p.x, p.z)
		p.y = ((da[c * 4] + da[c * 4 + 1]) * HS if c >= 0 else 0.0) + 0.08
		var dir := p - prev
		dir.y = 0.0
		var side := Vector3(-dir.z, 0, dir.x).normalized() * 0.09 if dir.length() > 0.001 else Vector3(0.09, 0, 0)
		im.surface_add_vertex(p - side)
		im.surface_add_vertex(p + side)
		prev = p
	im.surface_end()

func _reversals(pts: PackedVector2Array, axis: int, thr: float) -> int:
	var cnt := 0
	var dir := 0
	var anchor: float = pts[0][axis]
	for p in pts:
		var d: float = p[axis] - anchor
		if dir >= 0 and d < -thr:
			if dir > 0:
				cnt += 1
			dir = -1
			anchor = p[axis]
		elif dir <= 0 and d > thr:
			if dir < 0:
				cnt += 1
			dir = 1
			anchor = p[axis]
		elif (dir > 0 and d > 0.0) or (dir < 0 and d < 0.0):
			anchor = p[axis]
	return cnt

## 松手：认这一笔。横波浪是水，一竖是木，一个尖是石，来回涂是擦。认不出来的就散了。
func finish(pts: PackedVector2Array) -> String:
	ink_fade = 1.0
	if pts.size() < 3:
		return ""
	var lo := pts[0]
	var hi := pts[0]
	for p in pts:
		lo = lo.min(p)
		hi = hi.max(p)
	var W := hi.x - lo.x
	var H := hi.y - lo.y
	var rx := _reversals(pts, 0, 12.0)
	var ry := _reversals(pts, 1, 12.0)
	var first := pts[0]
	var last := pts[pts.size() - 1]
	var rmaj := rx if W >= H else ry
	if rmaj >= 2:
		var ids := {}
		for p in pts:
			var f := to_floor(p)
			for dz in range(-1, 2):
				for dx in range(-1, 2):
					var c := n.cell_at(f.x + dx, f.z + dz)
					if c >= 0 and Vector2(n.cell_pos(c).x - f.x, n.cell_pos(c).y - f.z).length() < 0.85:
						ids[c] = true
		if ids.is_empty():
			return ""
		n.erase(ids.keys())
		for c in ids:
			if c % 3 == 0:
				poof(Vector3(c % N - C, 0.4, c / N - C), Color(0.6, 0.45, 0.32))
		return "erase"
	if rx == 0 and ry == 1 and lo.y < minf(first.y, last.y) - 18.0:
		var f2 := to_floor((first + last) * 0.5)
		var c2 := n.cell_at(f2.x, f2.z)
		if c2 < 0:
			return ""
		n.raise(c2)
		poof(Vector3(f2.x, 1.5, f2.z), Color(0.81, 0.44, 0.24))
		return "stone"
	if W >= H and rx == 0 and ry >= 2:
		var ids2 := {}
		for p in pts:
			var f3 := to_floor(p)
			var c3 := n.cell_at(f3.x, f3.z)
			if c3 >= 0:
				ids2[c3] = true
		if ids2.is_empty():
			return ""
		n.add_water(ids2.keys(), 0.3)
		for c in ids2:
			poof(Vector3(c % N - C, 0.4, c / N - C), Color(0.6, 0.75, 0.82))
		return "water"
	if rx == 0 and ry == 0 and H > 1.8 * W and H > 25.0:
		var base := first if first.y > last.y else last
		var f4 := to_floor(base)
		var c4 := n.cell_at(f4.x, f4.z)
		if c4 < 0 or not n.plant(c4):
			return ""
		poof(Vector3(f4.x, 1.2, f4.z), Color(0.56, 0.66, 0.32))
		return "tree"
	return ""


# ---------------------------------------------------------------- 自动试玩与截图（只在设了 PINGZHONG_SHOT 时跑）
func _stroke(fpts: Array) -> String:
	var sp := PackedVector2Array()
	for p in fpts:
		sp.append(cam.unproject_position(Vector3(p.x, 0, p.y)))
	s_pts = sp
	var kind := finish(sp)
	return kind

func _wave(cx: float, cz: float, len: float) -> String:
	var a: Array = []
	for k in 25:
		var u := k / 24.0
		a.append(Vector2(cx + (u - 0.5) * len, cz + sin(u * TAU * 2.0) * 0.7))
	return _stroke(a)

func _line(cx: float, cz: float) -> String:
	var a: Array = []
	for k in 8:
		a.append(Vector2(cx, cz - 2.4 + k * 2.4 / 7.0))
	return _stroke(a)

func _peak(cx: float, cz: float) -> String:
	var a: Array = []
	for k in 9:
		var u := k / 8.0
		a.append(Vector2(cx - 1.3 + u * 2.6, cz - (1.0 - absf(u - 0.5) * 2.0) * 2.8))
	return _stroke(a)

func _scrub(cx: float, cz: float) -> String:
	var a: Array = []
	for k in 9:
		a.append(Vector2(cx + (-1.6 if k % 2 == 0 else 1.6), cz - 0.6 + k * 0.15))
	return _stroke(a)

func _shot(name_: String) -> void:
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("%s/%s.png" % [shot_dir, name_])
	print("截图 %s 年%.1f 暖%.0f 水%.1f 汽%.1f 云%.1f 草%d 林%d 鹿%d 狼%d" % [name_, n.time / Nature.YEAR, n.base, n.total_water(), n.vapor, n.cloud, n.grass_n, n.forest_n, n.deer.size(), n.wolves.size()])

func _until(sim_t: float) -> void:
	while n.time < sim_t:
		await get_tree().process_frame

func _shot_script() -> void:
	speed = 0.0
	await get_tree().create_timer(0.6).timeout
	await _shot("00-空瓶")
	var got: Array = []
	for x in [-7.0, -4.5, -2.0, 0.5, 3.0, 5.5]:
		got.append(_peak(x, -6.0))
	for q in 3:
		got.append(_wave(-3.0, 1.0 + q, 6.0))
		got.append(_wave(4.5, 5.0 + q * 0.5, 4.0))
	for p in [Vector2(2, 0), Vector2(3, 1), Vector2(4, -1), Vector2(-7, 3), Vector2(-6, 5), Vector2(0, 6), Vector2(6, 1), Vector2(7, 3)]:
		got.append(_line(p.x, p.y))
	print("认出的笔画 ", got)
	speed = 1.0
	await get_tree().create_timer(1.2).timeout
	await _shot("01-刚画完")
	s_pts = PackedVector2Array()
	for k in 30:
		s_pts.append(cam.unproject_position(Vector3(-8.0 + k * 0.2, 0, 7.0 + sin(k * 0.5) * 0.6)))
	drawing = true
	await get_tree().create_timer(0.1).timeout
	await _shot("02-正在画")
	drawing = false
	speed = 10.0
	var marks := [[24.0, "03-第一年夏"], [48.0, "04-第一年秋"], [72.0, "05-第一年冬"], [192.0, "06-第三年春"], [216.0, "07-第三年夏"], [240.0, "08-第三年秋"], [248.0, "08a-入冬一"], [253.0, "08b-入冬二"], [258.0, "08c-入冬三"], [264.0, "09-第三年冬"], [276.0, "09a-开春"]]
	for m in marks:
		await _until(m[0])
		await _shot(m[1])
	speed = 1.0
	toggle_web()
	await get_tree().create_timer(2.6).timeout
	await _shot("10-小瓶架")
	web.hover(cam.unproject_position(web.global_position + web.pos["fire"] + Vector3(0, 1.9, 0)))
	await get_tree().create_timer(1.5).timeout
	await _shot("11-小瓶架-看火")
	toggle_web()
	await get_tree().create_timer(1.2).timeout
	await _shot("12-回到瓶子")
	var kinds := {}
	for ev in n.events:
		var key: String = ev["t"] + (":" + ev["cause"] if ev.has("cause") else "") + (":" + ev["kind"] if ev.has("kind") else "")
		kinds[key] = kinds.get(key, 0) + 1
	print("发生过的事 ", kinds)
	get_tree().quit()
