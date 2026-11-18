extends SceneTree
## 无头自测：画一片水、几棵树、一排山，让自然自己跑八年，看水守不守恒、各样东西有没有发生。

func _init() -> void:
	var n := Nature.new()
	n.setup(7)
	var ids: Array = []
	for x in range(-4, 3):
		for z in range(0, 4):
			ids.append(n.cell_at(x, z))
	n.add_water(ids, 0.6)
	for x in range(-6, 7, 2):
		n.raise(n.cell_at(x, -7))
	for p in [Vector2(4, 2), Vector2(5, 3), Vector2(4, 4), Vector2(-6, 1), Vector2(-6, 3), Vector2(0, 5), Vector2(2, 5), Vector2(-2, 6), Vector2(5, 0), Vector2(6, 2)]:
		n.plant(n.cell_at(p.x, p.y))
	var w0 := n.total_water()
	var kinds := {}
	var ei := 0
	for q in 32:
		n.tick(Nature.YEAR / 4.0)
		while ei < n.events.size():
			var e: Dictionary = n.events[ei]
			var key: String = e["t"] + (":" + e["cause"] if e.has("cause") else "") + (":" + e["kind"] if e.has("kind") else "")
			kinds[key] = kinds.get(key, 0) + 1
			if e["t"] == "die" and kinds[key] <= 3:
				print("   死 ", e)
			ei += 1
		var sandy := 0
		var alg := 0
		for i in n.cells:
			if n.sand[i] > 0.5:
				sandy += 1
			if n.algae[i] > 0.5:
				alg += 1
		print("第%d年%d季 暖%.0f 水%.2f(初%.2f) 汽%.2f 云%.2f 水格%d 草%d 林%d 沙%d 藻%d 鹿%d 狼%d" % [q / 4 + 1, q % 4 + 1, n.base, n.total_water(), w0, n.vapor, n.cloud, n.water_n, n.grass_n, n.forest_n, sandy, alg, n.deer.size(), n.wolves.size()])
	print("发生过的事 ", kinds)
	quit()
