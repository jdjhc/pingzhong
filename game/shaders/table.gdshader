shader_type spatial;
render_mode unshaded;
// 瓶子底下的木桌。
uniform vec3 light = vec3(1.0);
uniform vec2 c2 = vec2(46.0, 0.0);     // 小瓶架那一头也亮着
varying vec3 wp;
float hash(vec2 p) { return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453); }
float noise(vec2 p) {
	vec2 i = floor(p); vec2 f = fract(p); f = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash(i), hash(i + vec2(1, 0)), f.x), mix(hash(i + vec2(0, 1)), hash(i + vec2(1, 1)), f.x), f.y);
}
void vertex() { wp = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz; }
void fragment() {
	vec2 p = wp.xz;
	float plank = floor(p.y / 9.0);
	float gr = noise(vec2(p.x * 0.12 + plank * 17.0, p.y * 2.2)) * 0.6 + noise(vec2(p.x * 0.5, p.y * 9.0 + plank * 5.0)) * 0.4;
	vec3 col = mix(vec3(0.3, 0.19, 0.13), vec3(0.47, 0.31, 0.2), gr);
	col *= 0.9 + 0.1 * hash(vec2(plank, 2.0));
	float seam = smoothstep(0.12, 0.0, abs(fract(p.y / 9.0) - 0.5) - 0.48 + 0.02);
	col *= 1.0 - 0.5 * seam;
	float r = length(p);
	col *= 0.45 + 0.55 * smoothstep(11.0, 17.0, r);          // 瓶子压在桌上的影子
	col *= 1.0 - 0.75 * smoothstep(25.0, 60.0, min(r, length(p - c2)));
	ALBEDO = pow(col * light, vec3(2.2));
}
