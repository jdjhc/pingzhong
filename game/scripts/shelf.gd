class_name Shelf
extends Node3D
## “？”：桌上一架小瓶子，一只装一样东西，装的是它在大瓶子里真正的样子。
## 三层按自然里的高低摆：上层是天上的，中层是地上活的，下层是地里的和水。
## 反应是演出来的：两只瓶子朝第三只倾过去，一道光从瓶口流进去，那只瓶子亮一下、鼓一下。
## 没人碰的时候一条一条轮着演；鼠标停在哪只瓶子上，就只演和它有关的。

const RX := [
	["water", "sun", "vapor"], ["vapor", "vapor", "cloud"], ["cloud", "tree", "rain"], ["cloud", "cold", "snow"],
	["water", "cold", "ice"], ["snow", "sun", "water"], ["ice", "sun", "water"],
	["rain", "soil", "mud"], ["water", "soil", "mud"], ["mud", "sun", "grass"],
	["soil", "wind", "sand"], ["sand", "grass", "soil"],
	["grass", "mud", "bush"], ["tree", "wind", "seed"], ["bush", "seed", "tree"],
	["grass", "sun", "hay"], ["tree", "sun", "log"], ["log", "mud", "rich"],
	["cloud", "sun", "bolt"], ["bolt", "hay", "fire"], ["bolt", "tree", "fire"],
	["fire", "tree", "char"], ["fire", "hay", "ash"], ["fire", "water", "vapor"],
	["ash", "soil", "rich"], ["char", "mud", "rich"],
	["grass", "water", "deer"], ["deer", "grass", "rich"], ["deer", "tree", "wolf"], ["wolf", "deer", "rich"],
]
const ROWS := [
	["sun", "cloud", "rain", "snow", "bolt", "wind", "cold", "vapor"],
	["grass", "hay", "bush", "seed", "tree", "deer", "wolf", "fire"],
	["soil", "mud", "sand", "rich", "ash", "char", "log", "water", "ice"],
]
const ROW_Y := [7.6, 3.8, 0.0]
const ROW_Z := [-4.8, 0.0, 4.8]
const CAM_POS := Vector3(0, 15.5, 27)
const CAM_LOOK := Vector3(0, 4.9, 0)
const S := 1.3                      # 小瓶子的大小
const WARM := Vector3(1.0, 0.95, 0.86)   # 架子自己的暖光，不跟大瓶子的冬夏走
const BLUE := Color(0.5, 0.78, 1.0)
const SKY := Color(0.95, 0.9, 0.78)
const GOLD := Color(1.0, 0.78, 0.35)
const FIRE := Color(1.0, 0.5, 0.18)
const LEAF := Color(0.6, 0.9, 0.4)
const EARTH := Color(0.9, 0.66, 0.44)
const BEAST := Color(1.0, 0.58, 0.36)
const TINT := {
	"water": BLUE, "rain": BLUE, "vapor": BLUE, "ice": BLUE, "snow": BLUE, "cold": BLUE,
	"cloud": SKY, "wind": SKY, "sun": GOLD, "bolt": GOLD, "hay": GOLD,
	"fire": FIRE, "ash": FIRE, "char": FIRE,
	"grass": LEAF, "bush": LEAF, "tree": LEAF, "seed": LEAF,
	"soil": EARTH, "mud": EARTH, "sand": EARTH, "rich": EARTH, "log": EARTH,
	"deer": BEAST, "wolf": BEAST,
}
## 每只小瓶瓶底的地：[石高, 水, 草木, 湿] [火, 雪, 灰, 肥] [沙, 枯, 藻, 朽木]
const GROUND := {
	"water": [0, 0.5, 0, 1, 0, 0, 0, 0.3, 0, 0, 0, 0], "ice": [0, 0.5, 0, 1, 0, 1, 0, 0.3, 0, 0, 0, 0],
	"vapor": [0, 0.4, 0, 1, 0, 0, 0, 0.3, 0, 0, 0, 0], "soil": [0, 0, 0, 0.6, 0, 0, 0, 0.25, 0, 0, 0, 0],
	"mud": [0, 0.055, 0, 1, 0, 0, 0, 0.5, 0, 0, 0, 0], "sand": [0, 0, 0, 0.5, 0, 0, 0, 0.1, 1, 0, 0, 0],
	"rich": [0, 0, 0.35, 0.9, 0, 0, 0, 1, 0, 0, 0, 0], "ash": [0, 0, 0, 0.5, 0, 0, 1, 0.3, 0, 0, 0, 0],
	"char": [0, 0, 0, 0.5, 0, 0, 0.7, 0.3, 0, 0, 0, 0], "log": [0, 0, 0.5, 0.7, 0, 0, 0, 0.4, 0, 0, 0, 0.9],
	"grass": [0, 0, 1.3, 0.8, 0, 0, 0, 0.4, 0, 0, 0, 0], "hay": [0, 0, 1.3, 0.5, 0, 0, 0, 0.3, 0, 1, 0, 0],
	"fire": [0, 0, 0.3, 0.5, 0.5, 0, 0.6, 0.3, 0, 1, 0, 0], "snow": [0, 0, 0, 0.6, 0, 1, 0, 0.3, 0, 0, 0, 0],
	"cold": [0, 0, 0.6, 0.6, 0, 0.5, 0, 0.3, 0, 0, 0, 0], "rain": [0, 0.055, 0.7, 1, 0, 0, 0, 0.4, 0, 0, 0, 0],
}
const PLAIN := [0, 0, 1.0, 0.7, 0, 0, 0, 0.35, 0, 0, 0, 0]

var view_cam: Camera3D
var pos := {}
var jars := {}
var floors := {}
var glass := {}
var stands := {}
var lit := {}
var lean := {}
var close_chip: MeshInstance3D
var lines: MeshInstance3D
var light := Vector3.ONE
var focus := ""
var active := false
var tt := 0.0
var rt := 0.0
var idx := 0
var playing: Array = RX
var atlas: Texture2D
var jar_mesh: ArrayMesh
var jar_shader: Shader
var floor_shader: Shader


func setup(cam: Camera3D, wood: Material) -> void:
	view_cam = cam
	atlas = Art.tex(Art.TREES, 1.0)
	jar_shader = load("res://shaders/jar.gdshader")
	floor_shader = load("res://shaders/floor.gdshader")
	for r in 2:                                   # 两级木台阶；最下一层直接摆在桌上
		var box := MeshInstance3D.new()
		var bm := BoxMesh.new()
		bm.size = Vector3(32.0, ROW_Y[r], 4.8)
		box.mesh = bm
		box.position = Vector3(0, ROW_Y[r] * 0.5, ROW_Z[r])
		box.material_override = wood
		add_child(box)
	var prof := [Vector2(1.25, 0), Vector2(1.25, 1.5), Vector2(1.15, 1.9), Vector2(0.8, 2.25), Vector2(0.62, 2.4), Vector2(0.6, 2.75), Vector2(0.68, 2.82)]
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for k in 28:
		var a0 := TAU * k / 28.0
		var a1 := TAU * (k + 1) / 28.0
		for p in prof.size() - 1:
			var p0: Vector2 = prof[p]
			var p1: Vector2 = prof[p + 1]
			var tg := (p1 - p0).normalized()
			var nr := Vector2(tg.y, -tg.x)
			for v in [[a0, p0], [a1, p0], [a1, p1], [a0, p0], [a1, p1], [a0, p1]]:
				var ang: float = v[0]
				var pp: Vector2 = v[1]
				st.set_normal(Vector3(cos(ang) * nr.x, nr.y, sin(ang) * nr.x))
				st.add_vertex(Vector3(cos(ang) * pp.x, pp.y, sin(ang) * pp.x))
	jar_mesh = st.commit()
	for r in 3:
		var row: Array = ROWS[r]
		for i in row.size():
			var nm: String = row[i]
			pos[nm] = Vector3((i - (row.size() - 1) * 0.5) * 3.5, ROW_Y[r], ROW_Z[r])
			_jar(nm)
	lines = MeshInstance3D.new()
	lines.mesh = ImmediateMesh.new()
	var lm := StandardMaterial3D.new()
	lm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	lm.vertex_color_use_as_albedo = true
	lm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	lm.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	lm.cull_mode = BaseMaterial3D.CULL_DISABLED
	lines.material_override = lm
	add_child(lines)
	close_chip = MeshInstance3D.new()
	var q := QuadMesh.new()
	q.size = Vector2(1.9, 1.9)
	close_chip.mesh = q
	var cm := StandardMaterial3D.new()
	cm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	cm.albedo_texture = Art.tex(Art.chip("help"), 2.0)
	close_chip.material_override = cm
	close_chip.position = Vector3(12.5, 1.0, 10.2)
	close_chip.rotation_degrees = Vector3(-52, -14, 0)
	add_child(close_chip)

func _px(a: float, b: float, c: float, d: float) -> ImageTexture:
	var img := Image.create(1, 1, false, Image.FORMAT_RGBAF)
	img.set_pixel(0, 0, Color(a, b, c, d))
	return ImageTexture.create_from_image(img)

func _flat(col: Color, add := false) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.albedo_color = col
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.vertex_color_use_as_albedo = true
	m.billboard_mode = BaseMaterial3D.BILLBOARD_PARTICLES
	if add:
		m.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	return m

func _stand(nm: String, tex: Texture2D, region: Rect2, height: float, at: Vector3) -> Sprite3D:
	var s := Sprite3D.new()
	s.texture = tex
	if region.size.x > 0.0:
		s.region_enabled = true
		s.region_rect = region
	var hpx := region.size.y if region.size.x > 0.0 else float(tex.get_height())
	s.pixel_size = height / hpx
	s.offset = Vector2(0, hpx * 0.5)
	s.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y
	s.shaded = false
	s.alpha_cut = SpriteBase3D.ALPHA_CUT_DISCARD
	s.position = at
	jars[nm].add_child(s)
	stands[nm].append(s)
	return s

func _puff(nm: String, col: Color, at: Vector3, px: float) -> Sprite3D:
	var s := Sprite3D.new()
	s.texture = Art.blob(col)
	s.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	s.shaded = false
	s.pixel_size = px
	s.position = at
	jars[nm].add_child(s)
	return s

func _motes(nm: String, col: Color, size: Vector2, amount: int, life: float, dir: Vector3, vel: float, at: Vector3, box: Vector3, add := false) -> CPUParticles3D:
	var p := CPUParticles3D.new()
	p.amount = amount
	p.lifetime = life
	p.preprocess = life
	p.local_coords = true
	var q := QuadMesh.new()
	q.size = size
	q.material = _flat(col, add)
	p.mesh = q
	p.position = at
	p.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
	p.emission_box_extents = box
	p.direction = dir
	p.spread = 6.0
	p.gravity = Vector3.ZERO
	p.initial_velocity_min = vel * 0.8
	p.initial_velocity_max = vel * 1.2
	jars[nm].add_child(p)
	return p

func _cell(k: int) -> Rect2:
	return Rect2(k * 160, 0, 160, 240)

func _jar(nm: String) -> void:
	var root := Node3D.new()
	root.position = pos[nm]
	root.scale = Vector3.ONE * S
	add_child(root)
	jars[nm] = root
	stands[nm] = []
	lit[nm] = 1.0
	lean[nm] = Vector3.ZERO
	var g: Array = GROUND.get(nm, PLAIN)
	var fl := MeshInstance3D.new()
	var pm := PlaneMesh.new()
	pm.size = Vector2(2.4, 2.4)
	fl.mesh = pm
	fl.position.y = 0.05
	var fm := ShaderMaterial.new()
	fm.shader = floor_shader
	fm.set_shader_parameter("ta", _px(g[0], g[1], g[2], g[3]))
	fm.set_shader_parameter("tb", _px(g[4], g[5], g[6], g[7]))
	fm.set_shader_parameter("tc", _px(g[8], g[9], g[10], g[11]))
	fm.set_shader_parameter("hs", 0.0)
	fm.set_shader_parameter("radius", 1.16)
	fm.set_shader_parameter("zoom", 3.2)
	fl.material_override = fm
	root.add_child(fl)
	floors[nm] = fm
	match nm:
		"tree":
			_stand(nm, atlas, _cell(0), 2.3, Vector3(0, 0.05, 0))
		"bush":
			_stand(nm, atlas, _cell(2), 1.7, Vector3(0, 0.05, 0))
		"seed":
			_stand(nm, Art.tex(Art.glyph("seed"), 3.0), Rect2(), 1.5, Vector3(0, 0.1, 0))
		"char":
			_stand(nm, atlas, _cell(3), 2.0, Vector3(0, 0.05, 0))
		"log":
			_stand(nm, Art.tex(Art.glyph("log"), 3.0), Rect2(), 1.7, Vector3(0, -0.2, 0.1))
		"deer":
			_stand(nm, Art.tex(Art.DEER, 1.5), Rect2(), 1.9, Vector3(0, 0.0, 0))
		"wolf":
			_stand(nm, Art.tex(Art.WOLF, 1.5), Rect2(), 1.8, Vector3(0, 0.0, 0))
		"sun":
			var s := MeshInstance3D.new()
			var sm := SphereMesh.new()
			sm.radius = 0.36
			sm.height = 0.72
			s.mesh = sm
			var m := StandardMaterial3D.new()
			m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
			m.albedo_color = Color(1, 0.86, 0.55)
			m.emission_enabled = true
			m.emission = Color(1, 0.8, 0.45)
			m.emission_energy_multiplier = 2.5
			s.material_override = m
			s.position = Vector3(0, 1.3, 0)
			root.add_child(s)
			_puff(nm, Color(1, 0.8, 0.45, 0.55), Vector3(0, 1.3, 0), 0.022)
		"cloud":
			for k in 3:
				_puff(nm, Color(0.9, 0.86, 0.78, 0.9), Vector3(-0.4 + k * 0.4, 1.35 + (k % 2) * 0.18, 0), 0.011)
		"rain":
			for k in 2:
				_puff(nm, Color(0.6, 0.6, 0.62, 0.95), Vector3(-0.25 + k * 0.5, 1.7, 0), 0.011)
			_motes(nm, Color(0.8, 0.9, 1.0, 0.85), Vector2(0.035, 0.28), 26, 0.32, Vector3.DOWN, 4.6, Vector3(0, 1.55, 0), Vector3(0.6, 0.05, 0.6))
		"snow":
			for k in 2:
				_puff(nm, Color(0.8, 0.82, 0.86, 0.95), Vector3(-0.25 + k * 0.5, 1.7, 0), 0.011)
			_motes(nm, Color(1, 1, 1, 0.95), Vector2(0.08, 0.08), 22, 1.6, Vector3.DOWN, 0.9, Vector3(0, 1.55, 0), Vector3(0.65, 0.05, 0.65))
		"bolt":
			for k in 2:
				_puff(nm, Color(0.42, 0.42, 0.48, 0.95), Vector3(-0.25 + k * 0.5, 1.75, 0), 0.011)
			var b := _stand(nm, Art.tex(Art.glyph("bolt"), 3.0), Rect2(), 1.5, Vector3(0, 0.1, 0.05))
			b.name = "flash"
		"wind":
			_motes(nm, Color(0.95, 0.9, 0.8, 0.8), Vector2(0.5, 0.035), 12, 0.7, Vector3.RIGHT, 2.6, Vector3(-0.8, 1.0, 0), Vector3(0.05, 0.6, 0.6))
			_motes(nm, Color(0.6, 0.75, 0.3, 0.95), Vector2(0.1, 0.07), 5, 0.7, Vector3.RIGHT, 2.4, Vector3(-0.8, 0.8, 0), Vector3(0.05, 0.5, 0.6))
		"cold":
			_motes(nm, Color(0.8, 0.92, 1.0, 0.9), Vector2(0.06, 0.06), 20, 2.4, Vector3(0.3, -1, 0), 0.5, Vector3(0, 1.3, 0), Vector3(0.7, 0.5, 0.7), true)
		"vapor":
			var v := _motes(nm, Color(0.85, 0.93, 1.0, 0.5), Vector2(0.3, 0.3), 12, 1.6, Vector3.UP, 0.9, Vector3(0, 0.3, 0), Vector3(0.6, 0.05, 0.6))
			(v.mesh as QuadMesh).material.albedo_texture = Art.blob(Color(1, 1, 1, 1))
		"fire":
			var ramp := Gradient.new()
			ramp.set_color(0, Color(1, 0.9, 0.4, 1))
			ramp.set_color(1, Color(0.6, 0.1, 0.02, 0))
			ramp.add_point(0.4, Color(1, 0.45, 0.1, 0.9))
			var f := _motes(nm, Color(1, 1, 1, 1), Vector2(0.4, 0.4), 22, 0.6, Vector3.UP, 1.8, Vector3(0, 0.25, 0), Vector3(0.35, 0.05, 0.35), true)
			f.color_ramp = ramp
			f.spread = 16.0
		"ash":
			_motes(nm, Color(0.75, 0.72, 0.7, 0.8), Vector2(0.05, 0.05), 10, 2.2, Vector3.UP, 0.35, Vector3(0, 0.2, 0), Vector3(0.6, 0.05, 0.6))
	var gl := MeshInstance3D.new()
	gl.mesh = jar_mesh
	var gm := ShaderMaterial.new()
	gm.shader = jar_shader
	var tc: Color = TINT[nm]
	gm.set_shader_parameter("glowc", Vector3(tc.r, tc.g, tc.b))
	gl.material_override = gm
	root.add_child(gl)
	glass[nm] = gm
	var cork := MeshInstance3D.new()
	var cmesh := CylinderMesh.new()
	cmesh.top_radius = 0.62
	cmesh.bottom_radius = 0.56
	cmesh.height = 0.42
	cork.mesh = cmesh
	cork.position.y = 2.95
	var km := StandardMaterial3D.new()
	km.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	km.albedo_color = Color(0.5, 0.35, 0.22)
	cork.material_override = km
	root.add_child(cork)

func hover(sp: Vector2) -> void:
	var was := focus
	focus = ""
	var best := 62.0
	for nm in pos:
		var w: Vector3 = global_transform * ((pos[nm] as Vector3) + Vector3(0, 1.9, 0))
		var d := view_cam.unproject_position(w).distance_to(sp)
		if d < best:
			best = d
			focus = nm
	if focus != was:
		playing = RX
		if focus != "":
			playing = RX.filter(func(r): return r.has(focus))
		idx = 0
		rt = 0.0

## 一道光：从一只瓶口拱到另一只瓶口，亮的那一段一直往前跑
func _flow(im: ImmediateMesh, p0: Vector3, p1: Vector3, col: Color, al: float) -> void:
	var ctrl := (p0 + p1) * 0.5 + Vector3(0, 2.2 + (p1 - p0).length() * 0.22, 0)
	var eye := to_local(view_cam.global_position)
	var prev := p0
	var pa := 0.0
	for k in 15:
		var u := k / 14.0
		var q := p0.lerp(ctrl, u).lerp(ctrl.lerp(p1, u), u)
		var a := al * (0.16 + 0.84 * pow(maxf(0.0, sin((u * 1.3 - rt * 1.5) * PI)), 6.0)) * minf(1.0, minf(u, 1.0 - u) * 8.0 + 0.2)
		if k > 0:
			var dir := (q - prev).normalized()
			var side := dir.cross((eye - q).normalized()).normalized() * 0.11
			var c0 := Color(col.r, col.g, col.b, pa)
			var c1 := Color(col.r, col.g, col.b, a)
			for v in [[prev - side, c0], [prev + side, c0], [q + side, c1], [prev - side, c0], [q + side, c1], [q - side, c1]]:
				im.surface_set_color(v[1])
				im.surface_add_vertex(v[0])
		prev = q
		pa = a

func _process(dt: float) -> void:
	tt += dt
	var im := lines.mesh as ImmediateMesh
	im.clear_surfaces()
	if not active:
		return
	rt += dt
	if rt > 2.8:
		rt = 0.0
		idx += 1
	var r: Array = playing[idx % playing.size()]
	var u := rt / 2.8
	var env := smoothstep(0.0, 0.15, u) * (1.0 - smoothstep(0.85, 1.0, u))
	var arrive := smoothstep(0.35, 0.6, u) * (1.0 - smoothstep(0.85, 1.0, u))
	var cpos: Vector3 = pos[r[2]]
	for nm in jars:
		var inp: bool = nm == r[0] or nm == r[1]
		var out: bool = nm == r[2]
		lit[nm] = lerpf(lit[nm], 1.15 if (inp or out) else 0.72, minf(1.0, dt * 6.0))
		var want := Vector3.ZERO
		if inp and not out:
			var d: Vector3 = cpos - pos[nm]
			d.y = 0.0
			if d.length() > 0.1:
				want = Vector3.UP.cross(d.normalized()) * 0.36 * env
		lean[nm] = (lean[nm] as Vector3).lerp(want, minf(1.0, dt * 7.0))
		var j: Node3D = jars[nm]
		var lv: Vector3 = lean[nm]
		var sc := 1.0 + (0.16 * arrive * (0.7 + 0.3 * sin(tt * 9.0)) if out else 0.0)
		j.basis = (Basis(lv.normalized(), lv.length()) if lv.length() > 0.001 else Basis()).scaled(Vector3.ONE * sc * S)
		var l: float = lit[nm]
		(floors[nm] as ShaderMaterial).set_shader_parameter("light", WARM * l)
		(floors[nm] as ShaderMaterial).set_shader_parameter("t", tt)
		(glass[nm] as ShaderMaterial).set_shader_parameter("glow", arrive if out else (env * 0.5 if inp else 0.0))
		for s in stands[nm]:
			(s as Sprite3D).modulate = Color(minf(1.0, WARM.x * l), minf(1.0, WARM.y * l), minf(1.0, WARM.z * l))
			if (s as Sprite3D).name == "flash":
				(s as Sprite3D).visible = fmod(tt * 0.8, 1.0) < 0.22
		if nm == "deer" or nm == "wolf":
			(stands[nm][0] as Sprite3D).position.y = absf(sin(tt * 6.0)) * 0.1
	im.surface_begin(Mesh.PRIMITIVE_TRIANGLES)
	var mouth: Vector3 = (jars[r[2]] as Node3D).transform * Vector3(0, 3.2, 0)
	_flow(im, (jars[r[0]] as Node3D).transform * Vector3(0, 3.2, 0), mouth, TINT[r[0]], env)
	if r[1] != r[0]:
		_flow(im, (jars[r[1]] as Node3D).transform * Vector3(0, 3.2, 0), mouth, TINT[r[1]], env)
	im.surface_end()
