class_name Art
extends RefCounted
## 立起来的那些纸片：草木、鹿、狼、桌上那张笔画卡。都是岩画的画法——赭红、炭黑、奶白，几笔成形。

const TREES := """<svg xmlns="http://www.w3.org/2000/svg" width="1280" height="240" viewBox="0 0 1280 240">
<g stroke-linecap="round" stroke-linejoin="round">
 <g>
  <path d="M80 236 L78 150 M79 186 L58 152 M80 176 L102 144" stroke="#5a3220" stroke-width="11" fill="none"/>
  <g fill="#2c3a1e"><circle cx="80" cy="92" r="60"/><circle cx="46" cy="126" r="38"/><circle cx="116" cy="122" r="40"/></g>
  <g fill="#6f8440"><circle cx="80" cy="92" r="52"/><circle cx="46" cy="126" r="30"/><circle cx="116" cy="122" r="32"/></g>
  <g fill="#8fa050"><circle cx="62" cy="76" r="22"/><circle cx="102" cy="98" r="17"/><circle cx="44" cy="120" r="12"/></g>
  <path d="M52 62 l8 -8 M96 60 l9 -6 M112 104 l8 -6 M70 110 l8 -7 M36 112 l6 -6" stroke="#dec69e" stroke-width="4" fill="none"/>
 </g>
 <g transform="translate(160,0)">
  <path d="M80 236 L80 130" stroke="#5a3220" stroke-width="11" fill="none"/>
  <path d="M80 10 L126 104 L104 100 L138 176 L22 176 L56 100 L34 104 Z" fill="#26331c" stroke="#26331c" stroke-width="8"/>
  <path d="M80 26 L112 94 L94 90 L122 166 L38 166 L66 90 L48 94 Z" fill="#5d7438"/>
  <path d="M80 40 L70 78 M80 40 L92 76 M60 120 L50 150 M82 118 L84 152 M100 122 L108 150" stroke="#84964a" stroke-width="6" fill="none"/>
  <path d="M74 56 l6 -8 M62 132 l6 -8 M96 136 l6 -8" stroke="#dec69e" stroke-width="4" fill="none"/>
 </g>
 <g transform="translate(320,0)">
  <path d="M80 236 L60 150 M80 236 L80 128 M80 236 L102 150" stroke="#5a3220" stroke-width="7" fill="none"/>
  <g fill="#2c3a1e"><circle cx="56" cy="132" r="36"/><circle cx="104" cy="130" r="38"/><circle cx="80" cy="94" r="38"/><circle cx="42" cy="176" r="24"/><circle cx="118" cy="174" r="24"/></g>
  <g fill="#7f9048"><circle cx="56" cy="132" r="29"/><circle cx="104" cy="130" r="31"/><circle cx="80" cy="94" r="31"/><circle cx="42" cy="176" r="17"/><circle cx="118" cy="174" r="17"/></g>
  <g fill="#9aaa58"><circle cx="70" cy="84" r="14"/><circle cx="96" cy="120" r="12"/><circle cx="48" cy="124" r="11"/></g>
  <g fill="#ce703e"><circle cx="66" cy="140" r="5"/><circle cx="96" cy="100" r="5"/><circle cx="112" cy="146" r="5"/><circle cx="46" cy="170" r="5"/></g>
 </g>
 <g transform="translate(480,0)" fill="none">
  <path d="M80 236 L78 126 L70 74 M78 156 L50 116 M79 176 L108 134 L118 104" stroke="#dec69e" stroke-width="17" opacity="0.35"/>
  <path d="M80 236 L78 126 L70 74 M78 156 L50 116 M79 176 L108 134 L118 104" stroke="#1a1412" stroke-width="12"/>
 </g>
 <g transform="translate(640,0)">
  <path d="M80 236 L80 112 M80 176 L58 152 M80 160 L104 138" stroke="#5a3220" stroke-width="7" fill="none"/>
  <g fill="#2c3a1e"><circle cx="80" cy="82" r="42"/><circle cx="54" cy="146" r="17"/><circle cx="108" cy="132" r="17"/></g>
  <g fill="#6f8440"><circle cx="80" cy="82" r="35"/><circle cx="54" cy="146" r="11"/><circle cx="108" cy="132" r="11"/></g>
  <g fill="#8fa050"><circle cx="68" cy="70" r="15"/></g>
  <path d="M62 62 l7 -7 M92 74 l7 -6" stroke="#dec69e" stroke-width="4" fill="none"/>
 </g>
 <g transform="translate(800,0)" fill="none">
  <path d="M80 236 L78 140 L62 96 L50 58 M78 140 L104 104 L118 64" stroke="#5a3220" stroke-width="10"/>
  <path d="M62 96 L38 90 M104 104 L126 100 M78 164 L54 138 M70 118 L84 78 L80 42 M84 78 L100 56 M50 58 L36 40 M118 64 L130 44 M56 76 L66 50" stroke="#5a3220" stroke-width="6"/>
  <path d="M48 52 L58 88 M38 86 L56 91 M106 98 L116 62 M110 99 L124 96 M82 40 L85 72 M56 134 L70 150 M100 52 L88 68" stroke="#eef0ee" stroke-width="4.5" transform="translate(-2,-5)"/>
 </g>
 <g transform="translate(960,0)" fill="none">
  <path d="M80 236 L56 150 L44 118 M56 150 L70 116 M80 236 L80 120 L72 90 M80 152 L96 110 M80 236 L104 152 L120 122 M104 152 L100 120" stroke="#5a3220" stroke-width="6"/>
  <path d="M44 118 L52 138 M70 116 L62 134 M72 90 L79 114 M96 110 L88 130 M120 122 L110 140" stroke="#eef0ee" stroke-width="4.5" transform="translate(-2,-5)"/>
 </g>
 <g transform="translate(1120,0)" fill="none">
  <path d="M80 236 L80 96 L70 58 M80 120 L98 80 M80 176 L58 150 M80 160 L104 136" stroke="#5a3220" stroke-width="6.5"/>
  <path d="M70 58 L78 90 M98 80 L88 100 M58 150 L70 164 M104 136 L92 148" stroke="#eef0ee" stroke-width="4.5" transform="translate(-2,-5)"/>
 </g>
</g></svg>"""

const DEER := """<svg xmlns="http://www.w3.org/2000/svg" width="96" height="96" viewBox="0 0 96 96">
<g fill="none" stroke="#ce703e" stroke-linecap="round" stroke-linejoin="round">
 <path d="M24 52 Q42 42 64 50" stroke-width="17"/>
 <path d="M64 48 L74 30" stroke-width="9"/>
 <path d="M72 30 L85 33" stroke-width="7"/>
 <path d="M27 56 L22 88 M35 58 L37 88 M58 58 L55 88 M66 56 L71 88" stroke-width="4.5"/>
 <path d="M20 48 L13 44" stroke-width="4"/>
</g>
<path d="M74 27 L70 10 M72 19 L63 13 M77 26 L83 10 M80 18 L89 14" fill="none" stroke="#dec69e" stroke-width="3" stroke-linecap="round"/>
<path d="M30 46 l5 3 M42 44 l5 3 M54 46 l5 3" fill="none" stroke="#f0e2c4" stroke-width="3" stroke-linecap="round"/>
</svg>"""

const WOLF := """<svg xmlns="http://www.w3.org/2000/svg" width="96" height="96" viewBox="0 0 96 96">
<g fill="none" stroke-linecap="round" stroke-linejoin="round">
 <g stroke="#dec69e">
  <path d="M22 58 Q42 50 66 56" stroke-width="19"/><path d="M66 54 L80 46" stroke-width="15"/><path d="M80 47 L92 52" stroke-width="10"/>
  <path d="M74 42 L72 31 M81 41 L84 30" stroke-width="9"/><path d="M20 56 L7 68" stroke-width="12"/>
  <path d="M25 62 L21 88 M33 62 L35 88 M58 62 L56 88 M66 62 L70 88" stroke-width="9"/>
 </g>
 <g stroke="#221a18">
  <path d="M22 58 Q42 50 66 56" stroke-width="14"/><path d="M66 54 L80 46" stroke-width="10"/><path d="M80 47 L92 52" stroke-width="5.5"/>
  <path d="M74 42 L72 31 M81 41 L84 30" stroke-width="4.5"/><path d="M20 56 L7 68" stroke-width="7"/>
  <path d="M25 62 L21 88 M33 62 L35 88 M58 62 L56 88 M66 62 L70 88" stroke-width="4.5"/>
 </g>
</g>
<circle cx="82" cy="45" r="2.2" fill="#e8b04c"/>
</svg>"""

## 桌上的卡：上面是你的笔画，下面是它活过来的样子。没有字。
const CARD := """<svg xmlns="http://www.w3.org/2000/svg" width="560" height="340" viewBox="0 0 560 340">
<path d="M8 12 L548 6 L554 330 L10 334 Z" fill="#dec69e" stroke="#7c5638" stroke-width="4" stroke-linejoin="round"/>
<path d="M140 30 L140 310 M280 30 L280 310 M420 30 L420 310" stroke="#7c5638" stroke-width="2" opacity="0.35"/>
<g fill="none" stroke="#96422a" stroke-width="8" stroke-linecap="round" stroke-linejoin="round">
 <path d="M30 86 q13 -24 26 0 t26 0 t26 0"/>
 <path d="M210 44 L210 124"/>
 <path d="M316 124 L350 46 L384 124"/>
 <path d="M452 52 L528 66 L452 82 L528 98 L452 114"/>
</g>
<g fill="none" stroke="#7c5638" stroke-width="4" stroke-linecap="round" stroke-linejoin="round">
 <path d="M70 150 L70 184 M60 174 L70 186 L80 174"/><path d="M210 150 L210 184 M200 174 L210 186 L220 174"/>
 <path d="M350 150 L350 184 M340 174 L350 186 L360 174"/><path d="M490 150 L490 184 M480 174 L490 186 L500 174"/>
</g>
<g stroke-linecap="round" stroke-linejoin="round">
 <ellipse cx="70" cy="262" rx="50" ry="34" fill="#1c2c36"/>
 <path d="M38 256 q8 -9 16 0 t16 0 t16 0 M46 274 q8 -9 16 0 t16 0" fill="none" stroke="#dec69e" stroke-width="4"/>
 <path d="M210 312 L210 262" stroke="#5a3220" stroke-width="9" fill="none"/>
 <circle cx="210" cy="240" r="34" fill="#2c3a1e"/><circle cx="210" cy="240" r="27" fill="#6f8440"/><circle cx="200" cy="230" r="11" fill="#8fa050"/>
 <path d="M300 310 L350 212 L400 310 Z" fill="#70503a" stroke="#3a2a20" stroke-width="5"/>
 <path d="M350 212 L338 262 M350 212 L364 270 M324 290 L340 270 M372 292 L360 276" fill="none" stroke="#ce703e" stroke-width="4"/>
 <circle cx="490" cy="262" r="36" fill="none" stroke="#7c5638" stroke-width="4" stroke-dasharray="3 12"/>
</g>
</svg>"""

## 元素的小图标：一样东西一个长相，不用字。
const ICONS := {
	"water": '<path d="M14 26 q6 -8 12 0 t12 0 t12 0 M14 38 q6 -8 12 0 t12 0 t12 0" fill="none" stroke="#8fc0d2" stroke-width="4.5" stroke-linecap="round"/>',
	"sun": '<circle cx="32" cy="32" r="10" fill="#e8b04c"/><path d="M32 12v6M32 46v6M12 32h6M46 32h6M18 18l4 4M42 42l4 4M46 18l-4 4M18 46l4 -4" stroke="#e8b04c" stroke-width="4" stroke-linecap="round"/>',
	"cold": '<path d="M32 12v40M15 22l34 20M15 42l34 -20M32 12l-5 6M32 12l5 6M32 52l-5 -6M32 52l5 -6" fill="none" stroke="#cfe6f0" stroke-width="3.5" stroke-linecap="round"/>',
	"wind": '<path d="M12 26h26q9 0 9 -7t-8 -6M12 38h32q9 0 9 7t-8 6M14 32h18" fill="none" stroke="#dec69e" stroke-width="4" stroke-linecap="round"/>',
	"soil": '<path d="M10 46 Q32 20 54 46 Z" fill="#8a5c3c" stroke="#dec69e" stroke-width="2.5"/>',
	"mud": '<path d="M10 48 Q32 26 54 48 Z" fill="#4a2e1e" stroke="#dec69e" stroke-width="2.5"/><path d="M32 12 q9 12 0 17 q-9 -5 0 -17" fill="#8fc0d2"/>',
	"rich": '<path d="M10 48 Q32 24 54 48 Z" fill="#241610" stroke="#dec69e" stroke-width="2.5"/><path d="M32 30v-12M32 22q-8 -1 -9 -8M32 20q8 -1 9 -8" fill="none" stroke="#8fa050" stroke-width="4" stroke-linecap="round"/>',
	"sand": '<path d="M10 46 Q32 24 54 46 Z" fill="#c7a878"/><g fill="#6a4a30"><circle cx="24" cy="40" r="2"/><circle cx="32" cy="34" r="2"/><circle cx="40" cy="41" r="2"/><circle cx="33" cy="43" r="2"/><circle cx="46" cy="44" r="2"/><circle cx="18" cy="44" r="2"/></g>',
	"vapor": '<path d="M20 50 q-6 -8 0 -14 t0 -14 M32 52 q-6 -9 0 -16 t0 -16 M44 50 q-6 -8 0 -14 t0 -14" fill="none" stroke="#cfe6f0" stroke-width="4" stroke-linecap="round"/>',
	"cloud": '<path d="M16 42 a9 9 0 0 1 2 -18 a12 12 0 0 1 23 -3 a10 10 0 0 1 6 21 Z" fill="#dec69e"/>',
	"rain": '<path d="M16 32 a8 8 0 0 1 2 -15 a11 11 0 0 1 21 -3 a9 9 0 0 1 6 18 Z" fill="#dec69e"/><path d="M22 38l-4 12M32 38l-4 12M42 38l-4 12" stroke="#8fc0d2" stroke-width="4" stroke-linecap="round"/>',
	"snow": '<g fill="#f4f1e8"><circle cx="20" cy="20" r="4.5"/><circle cx="40" cy="18" r="4.5"/><circle cx="30" cy="32" r="4.5"/><circle cx="46" cy="36" r="4.5"/><circle cx="18" cy="42" r="4.5"/><circle cx="36" cy="48" r="4.5"/></g>',
	"ice": '<path d="M32 12 L50 32 L32 52 L14 32 Z" fill="#b8d8e4" stroke="#f4f1e8" stroke-width="2.5"/><path d="M32 12 L28 30 L38 36 L32 52 M28 30 L14 32" fill="none" stroke="#5e8a9c" stroke-width="2.5"/>',
	"grass": '<path d="M20 48 L24 28 M32 48 L32 20 M44 48 L40 28 M26 48 L18 36 M38 48 L47 36" fill="none" stroke="#8fa050" stroke-width="4.5" stroke-linecap="round"/>',
	"hay": '<path d="M18 48 L28 30 M30 48 L42 26 M42 48 L52 34 M24 48 L14 38" fill="none" stroke="#e8b04c" stroke-width="4.5" stroke-linecap="round"/>',
	"bush": '<circle cx="24" cy="38" r="12" fill="#7f9048"/><circle cx="40" cy="38" r="12" fill="#7f9048"/><circle cx="32" cy="28" r="12" fill="#8fa050"/><g fill="#ce703e"><circle cx="26" cy="38" r="2.6"/><circle cx="38" cy="32" r="2.6"/><circle cx="42" cy="42" r="2.6"/></g>',
	"seed": '<path d="M32 50 q-11 -8 0 -22 q11 14 0 22" fill="#b98a52"/><path d="M32 28 v-10 M32 22 q-7 0 -8 -7 M32 20 q7 0 8 -7" fill="none" stroke="#8fa050" stroke-width="3.5" stroke-linecap="round"/>',
	"tree": '<path d="M32 54 L32 34" stroke="#8a5432" stroke-width="6" stroke-linecap="round"/><circle cx="32" cy="26" r="16" fill="#6f8440"/><circle cx="27" cy="21" r="6" fill="#8fa050"/>',
	"log": '<path d="M12 40 L46 30" stroke="#6a4028" stroke-width="13" stroke-linecap="round"/><circle cx="47" cy="30" r="6.5" fill="#c7a878"/><circle cx="47" cy="30" r="2.5" fill="#6a4028"/><path d="M24 30 l-4 -8" stroke="#6a4028" stroke-width="4" stroke-linecap="round"/>',
	"bolt": '<path d="M38 10 L20 34 H31 L25 54 L46 28 H35 Z" fill="#e8b04c"/>',
	"fire": '<path d="M32 10 q16 18 10 32 a11 11 0 0 1 -21 0 q-3 -8 4 -16 q1 8 5 8 q-2 -12 2 -24" fill="#ce703e"/><path d="M32 30 q7 9 4 16 a5 5 0 0 1 -9 0 q-1 -6 5 -16" fill="#e8b04c"/>',
	"char": '<path d="M32 54 L31 24 L26 12 M31 36 L20 26 M32 42 L44 30 L48 20" fill="none" stroke="#c9bfae" stroke-width="9" stroke-linecap="round" stroke-linejoin="round"/><path d="M32 54 L31 24 L26 12 M31 36 L20 26 M32 42 L44 30 L48 20" fill="none" stroke="#151110" stroke-width="5.5" stroke-linecap="round" stroke-linejoin="round"/>',
	"ash": '<path d="M12 46 Q32 30 52 46 Z" fill="#8a8580"/><g fill="#d8d2c8"><circle cx="24" cy="26" r="2.4"/><circle cx="36" cy="20" r="2.4"/><circle cx="42" cy="30" r="2.4"/><circle cx="30" cy="32" r="2.4"/></g>',
	"deer": '<g transform="translate(6,8) scale(0.54)"><g fill="none" stroke="#ce703e" stroke-linecap="round"><path d="M24 52 Q42 42 64 50" stroke-width="17"/><path d="M64 48 L74 30" stroke-width="9"/><path d="M72 30 L85 33" stroke-width="7"/><path d="M27 56 L22 88 M35 58 L37 88 M58 58 L55 88 M66 56 L71 88" stroke-width="5"/></g><path d="M74 27 L70 10 M72 19 L63 13 M77 26 L83 10 M80 18 L89 14" fill="none" stroke="#dec69e" stroke-width="4" stroke-linecap="round"/></g>',
	"wolf": '<g transform="translate(6,6) scale(0.54)" fill="none" stroke-linecap="round"><g stroke="#dec69e"><path d="M22 58 Q42 50 66 56" stroke-width="20"/><path d="M66 54 L80 46" stroke-width="16"/><path d="M80 47 L92 52" stroke-width="11"/><path d="M74 42 L72 31 M81 41 L84 30" stroke-width="10"/><path d="M20 56 L7 68" stroke-width="13"/><path d="M25 62 L21 88 M33 62 L35 88 M58 62 L56 88 M66 62 L70 88" stroke-width="10"/></g><g stroke="#221a18"><path d="M22 58 Q42 50 66 56" stroke-width="14"/><path d="M66 54 L80 46" stroke-width="10"/><path d="M80 47 L92 52" stroke-width="5.5"/><path d="M74 42 L72 31 M81 41 L84 30" stroke-width="4.5"/><path d="M20 56 L7 68" stroke-width="7"/><path d="M25 62 L21 88 M33 62 L35 88 M58 62 L56 88 M66 62 L70 88" stroke-width="4.5"/></g></g>',
}

const PLUS := """<svg xmlns="http://www.w3.org/2000/svg" width="48" height="48" viewBox="0 0 48 48">
<circle cx="24" cy="24" r="20" fill="#221a18" stroke="#dec69e" stroke-width="3"/>
<path d="M24 13v22M13 24h22" stroke="#dec69e" stroke-width="5" stroke-linecap="round"/></svg>"""

const MARKS := {
	"pause": '<path d="M36 28v40M60 28v40" stroke="#96422a" stroke-width="11" stroke-linecap="round"/>',
	"play": '<path d="M36 26 L68 48 L36 70 Z" fill="#96422a" stroke="#96422a" stroke-width="5" stroke-linejoin="round"/>',
	"fast": '<path d="M22 28 L48 48 L22 68 Z M50 28 L76 48 L50 68 Z" fill="#96422a" stroke="#96422a" stroke-width="5" stroke-linejoin="round"/>',
	"help": '<path d="M34 36 q0 -14 14 -14 q14 0 14 12 q0 9 -9 13 q-5 3 -5 9" fill="none" stroke="#96422a" stroke-width="9" stroke-linecap="round"/><circle cx="48" cy="72" r="5.5" fill="#96422a"/>',
}

## 只有那一笔图形，没有底下的圆盘（关系网里的玻璃球用）
static func glyph(nm: String) -> String:
	return '<svg xmlns="http://www.w3.org/2000/svg" width="64" height="64" viewBox="0 0 64 64">' + ICONS[nm] + '</svg>'

static func icon(nm: String) -> String:
	return '<svg xmlns="http://www.w3.org/2000/svg" width="64" height="64" viewBox="0 0 64 64"><circle cx="32" cy="32" r="30" fill="#33231a" stroke="#7c5638" stroke-width="2.5"/>' + ICONS[nm] + '</svg>'

## 桌上的小木牌（暂停、一倍、两倍、问号）
static func chip(nm: String) -> String:
	return '<svg xmlns="http://www.w3.org/2000/svg" width="96" height="96" viewBox="0 0 96 96"><path d="M8 10 L88 6 L90 88 L6 90 Z" fill="#dec69e" stroke="#7c5638" stroke-width="4" stroke-linejoin="round"/>' + MARKS[nm] + '</svg>'

static func tex(svg: String, scale: float = 1.0) -> ImageTexture:
	var img := Image.new()
	img.load_svg_from_string(svg, scale)
	img.generate_mipmaps()
	return ImageTexture.create_from_image(img)

static func blob(col: Color) -> GradientTexture2D:
	var g := Gradient.new()
	g.set_color(0, col)
	g.set_color(1, Color(col.r, col.g, col.b, 0.0))
	var t := GradientTexture2D.new()
	t.gradient = g
	t.fill = GradientTexture2D.FILL_RADIAL
	t.fill_from = Vector2(0.5, 0.5)
	t.fill_to = Vector2(1.0, 0.5)
	t.width = 128
	t.height = 128
	return t
