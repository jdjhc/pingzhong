shader_type spatial;
render_mode unshaded, cull_disabled, world_vertex_coords;
// 立在瓶底的草木：一张张朝着你的纸片。春天开花，夏天最绿，秋天变黄变红，冬天阔叶的换成光枝带雪、尖顶的顶上积雪。

uniform sampler2D atlas : source_color, filter_linear_mipmap, repeat_disable;
uniform float t = 0.0;
uniform float wind = 0.5;
uniform float yp = 0.25;            // 一年走到哪了：0 春 · 0.25 夏 · 0.5 秋 · 0.75 冬
uniform float spread = 0.06;        // 每棵树的节气早晚能差多少年
uniform vec3 light = vec3(1.0);
varying float burn;
varying float kind;
varying float ph;
varying vec2 luv;
varying float bare;
varying float fall;
varying vec4 sea;                   // 这棵树自己的 春 夏 秋 冬

float hash(vec2 p) { return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453); }
float noise(vec2 p) {
	vec2 i = floor(p); vec2 f = fract(p); f = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash(i), hash(i + vec2(1, 0)), f.x), mix(hash(i + vec2(0, 1)), hash(i + vec2(1, 1)), f.x), f.y);
}

void vertex() {
	vec3 origin = MODEL_MATRIX[3].xyz;
	float sx = length(MODEL_MATRIX[0].xyz);
	float sy = length(MODEL_MATRIX[1].xyz);
	vec3 right = normalize(vec3(INV_VIEW_MATRIX[0].x, 0.0, INV_VIEW_MATRIX[0].z));
	vec2 l = vec2(UV.x - 0.5, 1.0 - UV.y);
	ph = INSTANCE_CUSTOM.z;
	l.x += sin(t * 1.6 + ph * 6.28) * 0.05 * l.y * wind;
	VERTEX = origin + right * l.x * sx + vec3(0.0, 1.0, 0.0) * l.y * sy;
	burn = INSTANCE_CUSTOM.y;
	float k = INSTANCE_CUSTOM.x;
	float y = 6.2831853 * (yp + (fract(ph * 7.31 + 0.37) - 0.5) * spread);   // 每棵树有自己的早晚
	sea = vec4(max(0.0, cos(y)), max(0.0, sin(y)), max(0.0, -cos(y)), max(0.0, -sin(y)));
	bare = -1.0;                                  // 阔叶的有一张光枝的样子
	if (k < 0.5) bare = 5.0;
	else if (abs(k - 2.0) < 0.5) bare = 6.0;
	else if (abs(k - 4.0) < 0.5) bare = 7.0;
	fall = smoothstep(0.15 + fract(ph * 3.17) * 0.12, 0.75 + fract(ph * 3.17) * 0.12, sea.w);   // 叶子一片片掉：每棵树早晚差几天
	kind = k;
	luv = UV;
}

void fragment() {
	vec4 c = texture(atlas, vec2((luv.x + kind) / 8.0, luv.y));
	float gone = 0.0;
	if (bare > 0.0 && fall > 0.001) {
		float n = noise(luv * vec2(9.0, 13.0) + ph * 13.0) * 0.7 + noise(luv * vec2(23.0, 31.0) + ph * 5.0) * 0.3;
		gone = step(n * 0.8 + 0.1, fall * 1.02);                    // 一团团地秃，从零到全秃
		if (gone > 0.5) c = texture(atlas, vec2((luv.x + bare) / 8.0, luv.y));
	}
	if (c.a < 0.5) discard;
	vec3 col = c.rgb;
	float green = smoothstep(0.004, 0.03, c.g - c.r);
	float leafy = green * (abs(kind - 1.0) < 0.5 ? 0.0 : 1.0);
	float lum = clamp(dot(col, vec3(0.3, 0.6, 0.1)) / 0.16, 0.45, 1.7);
	col = mix(col, col * 1.3 + vec3(0.01, 0.03, 0.0), green * sea.x * 0.6);
	vec2 g = luv * vec2(9.0, 13.5) + ph * 7.0;                      // 春天的花：一朵朵圆的
	float bloom = smoothstep(0.36, 0.26, length(fract(g) - 0.5)) * step(0.68, hash(floor(g) + ph * 31.0));
	col = mix(col, vec3(0.9, 0.5, 0.55), leafy * sea.x * bloom);
	vec3 au = mix(vec3(0.62, 0.3, 0.03), vec3(0.42, 0.07, 0.02), fract(ph * 3.7)) * lum;
	float old = clamp(sea.z + sea.w * 1.5 - sea.x * 3.0, 0.0, 1.0);   // 入冬还挂着的叶子不会变回绿
	au = mix(au, au * vec3(0.7, 0.55, 0.5), sea.w * (1.0 - sea.x));        // 越冷越枯
	col = mix(col, au, leafy * old * 0.92 * (1.0 - gone));
	float cap = smoothstep(0.42, 0.56, noise(luv * vec2(5.0, 8.0) + ph * 9.0)) * smoothstep(0.2, 0.55, 1.0 - luv.y);
	col = mix(col, vec3(0.86, 0.88, 0.89), (green - leafy) * sea.w * cap);         // 松树顶上的雪：一团团软的
	col = mix(col, vec3(1.0, 0.25, 0.02) * (0.8 + 0.4 * sin(t * 20.0 + UV.y * 30.0)), burn * 0.8);
	ALBEDO = col * mix(light, vec3(1.0), burn);
}
