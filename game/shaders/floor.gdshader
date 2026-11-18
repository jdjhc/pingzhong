shader_type spatial;
render_mode unshaded, cull_disabled;
// 瓶底：一张兽皮。地、水、草、沙、雪、灰全画在这一张上，颜色照“原始·兽皮上的岩画”那一套。

uniform sampler2D ta : filter_linear, repeat_disable;   // 石高 · 水 · 草木 · 湿
uniform sampler2D tb : filter_linear, repeat_disable;   // 火 · 雪冰 · 灰 · 肥
uniform sampler2D tc : filter_linear, repeat_disable;   // 沙 · 枯 · 藻 · 朽木
uniform float hs = 1.3;
uniform float radius = 11.75;
uniform float zoom = 1.0;       // 架子上的小瓶子用同一张地，只是凑近了看
uniform float t = 0.0;
uniform vec3 light = vec3(1.0);
uniform vec4 season = vec4(0.0, 1.0, 0.0, 0.0);     // 春 夏 秋 冬
varying vec3 wp;

float hash(vec2 p) { return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453); }
float noise(vec2 p) {
	vec2 i = floor(p); vec2 f = fract(p); f = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash(i), hash(i + vec2(1, 0)), f.x), mix(hash(i + vec2(0, 1)), hash(i + vec2(1, 1)), f.x), f.y);
}
float fbm(vec2 p) { return noise(p) * 0.5 + noise(p * 2.1) * 0.3 + noise(p * 4.3) * 0.2; }

void vertex() {
	vec4 a = texture(ta, UV);
	VERTEX.y = (a.r + a.g) * hs;
	wp = VERTEX;
}

void fragment() {
	float r = length(wp.xz);
	if (r > radius) discard;
	vec2 p = wp.xz * zoom;
	vec4 a = texture(ta, UV);
	vec4 b = texture(tb, UV);
	vec4 c = texture(tc, UV);
	float n1 = fbm(p * 0.55);
	float n2 = noise(p * 2.7);
	float n3 = noise(p * 13.0);

	// 兽皮
	vec3 col = mix(vec3(0.337, 0.227, 0.157), vec3(0.439, 0.298, 0.196), n1) * (0.88 + 0.24 * n3);
	col *= 1.0 - 0.3 * smoothstep(0.3, 0.9, b.a);                    // 肥土偏黑
	col *= 1.0 - 0.22 * smoothstep(0.4, 1.0, a.a);                   // 湿的发深

	// 沙：浅色加点
	float sd = smoothstep(0.25, 0.8, c.r + (n2 - 0.5) * 0.3);
	col = mix(col, vec3(0.78, 0.66, 0.47), sd * 0.75);
	vec2 sq = p * 5.0;
	float dot_ = smoothstep(0.22, 0.1, length(fract(sq) - 0.5 - (vec2(hash(floor(sq)), hash(floor(sq) + 9.1)) - 0.5) * 0.5));
	col = mix(col, vec3(0.42, 0.29, 0.2), sd * dot_ * 0.6);

	// 干裂：又干又光的地
	float crack = (1.0 - smoothstep(0.1, 0.4, a.a)) * (1.0 - smoothstep(0.2, 0.7, a.b)) * (1.0 - sd);
	vec2 cq = p * 1.6 + vec2(n2, n1) * 0.7;
	vec2 cf = abs(fract(cq) - 0.5);
	float cl = 1.0 - smoothstep(0.0, 0.035, min(cf.x, cf.y));
	col = mix(col, col * 0.62, crack * cl * 0.8);

	// 草：一片底色加一根根短笔
	float g = smoothstep(0.2, 1.0, a.b + (n2 - 0.5) * 0.35);
	vec3 gcol = vec3(0.46, 0.53, 0.26);
	gcol = mix(gcol, vec3(0.5, 0.65, 0.28), season.x * 0.8);
	gcol = mix(gcol, vec3(0.72, 0.56, 0.26), season.z * 0.7);
	gcol = mix(gcol, vec3(0.47, 0.43, 0.3), season.w * 0.8);
	gcol = mix(gcol, vec3(0.86, 0.66, 0.3), c.g);
	col = mix(col, mix(col, gcol, 0.45), g);
	vec2 tq = vec2(p.x * 4.2, p.y * 2.6);
	vec2 tid = floor(tq);
	vec2 tf = fract(tq) - 0.5;
	float tx = (hash(tid) - 0.5) * 0.6;
	float lean = (hash(tid + 3.3) - 0.5) * 0.5 + sin(t * 1.3 + p.x * 0.7) * 0.12;
	float tick = smoothstep(0.09, 0.03, abs(tf.x - tx - lean * tf.y)) * smoothstep(0.42, 0.3, abs(tf.y));
	tick *= step(hash(tid + 7.7), g * 0.9);
	col = mix(col, gcol * 1.35, tick);

	// 林下
	float fo = smoothstep(2.0, 2.8, a.b);
	col = mix(col, col * 0.55 + vec3(0.05, 0.08, 0.03), fo * 0.7);

	// 春天草里开花，秋天林下落叶
	vec2 fq = p * 3.1;
	vec2 fid = floor(fq);
	float fl = smoothstep(0.2, 0.1, length(fract(fq) - 0.5 - (vec2(hash(fid + 1.7), hash(fid + 4.2)) - 0.5) * 0.6));
	float fh = hash(fid + 11.0);
	vec3 fc = fh < 0.33 ? vec3(0.93, 0.6, 0.62) : (fh < 0.66 ? vec3(0.94, 0.89, 0.77) : vec3(0.91, 0.69, 0.3));
	col = mix(col, fc, fl * g * season.x * step(0.5, hash(fid + 2.9)) * (1.0 - c.g) * (1.0 - fo));
	vec3 lc = hash(fid + 8.0) < 0.5 ? vec3(0.8, 0.45, 0.15) : vec3(0.65, 0.22, 0.1);
	col = mix(col, lc, fl * smoothstep(1.6, 2.4, a.b) * season.z * step(0.35, hash(fid + 6.1)));

	// 朽木、炭：横躺的短黑笔
	vec2 dq = vec2(p.x * 1.7 + n2, p.y * 4.5);
	float dl = smoothstep(0.16, 0.06, abs(fract(dq.y) - 0.5)) * step(hash(floor(dq)), 0.5);
	col = mix(col, vec3(0.1, 0.07, 0.06), smoothstep(0.15, 0.6, c.a) * dl * 0.85);

	// 石：等高线
	float rock = smoothstep(0.75, 1.25, a.r + (n2 - 0.5) * 0.3);
	vec3 rc = mix(vec3(0.3, 0.22, 0.18), vec3(0.52, 0.4, 0.3), n1) * (0.85 + 0.3 * n3);
	rc = mix(rc, vec3(0.87, 0.78, 0.62), smoothstep(2.1, 2.9, a.r) * 0.6);
	float ln = abs(fract(a.r * 3.5 + n2 * 0.12) - 0.5);
	float line = 1.0 - smoothstep(0.03, 0.09, ln);
	col = mix(col, rc, rock);
	col = mix(col, vec3(0.81, 0.44, 0.24), rock * line * 0.75);

	// 灰
	col = mix(col, vec3(0.07, 0.06, 0.06), smoothstep(0.1, 0.8, b.b) * 0.85);

	// 水：深色，上面是一圈圈浅色波纹
	float wd = a.g;
	float wm = smoothstep(0.035, 0.08, wd + (n2 - 0.5) * 0.02);
	vec3 wc = mix(vec3(0.16, 0.25, 0.3), vec3(0.07, 0.12, 0.17), smoothstep(0.05, 0.7, wd));
	wc = mix(wc, vec3(0.3, 0.38, 0.14), smoothstep(0.2, 0.9, c.b));          // 藻
	float rp = abs(fract(wd * 9.0 - t * 0.12 + n1 * 0.8) - 0.5);
	float rl = (1.0 - smoothstep(0.02, 0.07, rp)) * (0.55 - 0.35 * smoothstep(0.1, 0.8, wd));
	wc = mix(wc, vec3(0.87, 0.78, 0.62), rl);
	float shore = smoothstep(0.035, 0.06, wd) * (1.0 - smoothstep(0.07, 0.11, wd));
	wc = mix(wc, vec3(0.94, 0.89, 0.77), shore * 0.7);
	float icy = smoothstep(0.4, 0.8, b.g) * wm;
	vec3 icec = vec3(0.8, 0.86, 0.88) * (0.9 + 0.1 * n3);
	icec = mix(icec, vec3(0.45, 0.55, 0.6), cl * 0.6);
	wc = mix(wc, icec, icy);
	col = mix(col, wc, wm);

	// 雪、霜
	float sn = smoothstep(0.15, 0.7, b.g + (n2 - 0.5) * 0.35) * (1.0 - wm);
	col = mix(col, vec3(0.92, 0.9, 0.84), sn * 0.85);

	// 火光
	col += vec3(1.0, 0.45, 0.1) * b.r * (0.5 + 0.4 * sin(t * 18.0 + n3 * 6.0));

	col *= light;
	col *= 1.0 - 0.55 * smoothstep(radius * 0.877, radius, r);
	ALBEDO = pow(max(col, vec3(0.0)), vec3(2.2));
}
