shader_type spatial;
render_mode unshaded, blend_mix, cull_disabled, depth_draw_never;
// 玻璃：汽在上面结成水珠，湿了起雾，冷了从背面结霜，烟多了发灰。

uniform float vapor = 0.0;
uniform float fog = 0.0;
uniform float frost = 0.0;
uniform float smoke = 0.0;
uniform float t = 0.0;
varying vec3 wp;

float hash(vec2 p) { return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453); }
float noise(vec2 p) {
	vec2 i = floor(p); vec2 f = fract(p); f = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash(i), hash(i + vec2(1, 0)), f.x), mix(hash(i + vec2(0, 1)), hash(i + vec2(1, 1)), f.x), f.y);
}

void vertex() { wp = VERTEX; }

void fragment() {
	float fres = pow(1.0 - abs(dot(normalize(NORMAL), normalize(VIEW))), 3.0);
	vec3 col = vec3(0.86, 0.93, 0.95);
	float back = FRONT_FACING ? 0.0 : 1.0;      // 朝着你的那一面几乎是空的，东西都结在背面
	float a = 0.006 + fres * mix(0.1, 0.22, back);
	float ang = atan(wp.z, wp.x);
	float hl = smoothstep(0.05, 0.0, abs(ang - 0.95)) * smoothstep(1.0, 3.0, wp.y) * smoothstep(7.5, 5.5, wp.y);
	hl += smoothstep(0.02, 0.0, abs(ang - 1.12)) * smoothstep(2.0, 3.5, wp.y) * smoothstep(6.5, 5.0, wp.y) * 0.6;
	a += hl * 0.3;

	vec2 g = vec2(ang * 16.0, wp.y * 1.3);
	vec2 id = floor(g);
	vec2 f = fract(g) - 0.5;
	float hy = smoothstep(2.0, 7.0, wp.y) * back;
	float on = step(hash(id), vapor * hy);
	vec2 o = (vec2(hash(id + 3.1), hash(id + 7.7)) - 0.5) * 0.5;
	float rad = 0.08 + 0.14 * hash(id + 1.3);
	float d = length((f - o) * vec2(1.0, 0.8));
	float drop = on * smoothstep(rad, rad * 0.55, d);
	float spec = on * smoothstep(rad * 0.35, 0.0, length(f - o - vec2(-0.05, 0.07)));
	col = mix(col, vec3(0.7, 0.8, 0.84), drop * 0.5);
	col = mix(col, vec3(1.0), spec);
	a = max(a, drop * 0.4 + spec * 0.5);

	a += back * fog * 0.14 * smoothstep(3.0, 9.0, wp.y) * (0.6 + 0.4 * noise(vec2(ang * 3.0, wp.y * 0.4 - t * 0.05)));

	float fn = noise(vec2(ang * 9.0, wp.y * 1.6)) * 0.6 + noise(vec2(ang * 30.0, wp.y * 5.0)) * 0.4;
	float fr = back * 0.75 * frost * (1.0 - smoothstep(-0.5, 0.3, wp.z / 12.0 + (fn - 0.5) * 0.6 - frost * 0.9 + 0.5));
	col = mix(col, vec3(0.95, 0.98, 1.0), fr);
	a = max(a, fr * (0.35 + 0.4 * fn));

	float sm = back * smoke * smoothstep(4.0, 10.0, wp.y);
	col = mix(col, vec3(0.28, 0.26, 0.25), sm);
	a += sm * 0.3;
	ALBEDO = col;
	ALPHA = clamp(a, 0.0, 0.9);
}
