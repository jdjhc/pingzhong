shader_type spatial;
render_mode unshaded, blend_mix, cull_disabled, depth_draw_never;
// 架子上的小瓶子：和大瓶子一样的玻璃，被点到时边缘泛出里面那样东西的颜色。
uniform vec3 glowc = vec3(1.0);
uniform float glow = 0.0;
void fragment() {
	float f = pow(1.0 - abs(dot(normalize(NORMAL), normalize(VIEW))), 3.0);
	ALBEDO = mix(vec3(0.86, 0.93, 0.95), glowc, glow * 0.8);
	ALPHA = clamp(0.02 + f * (0.3 + glow * 0.5), 0.0, 0.9);
}
