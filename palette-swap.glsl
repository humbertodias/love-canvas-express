uniform sampler2D palette;

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
	vec2 u = Texel(texture, texture_coords).ra;
	vec4 pixel = Texel(palette, vec2(u.r + 0.5f / 8, 0.5f));
	pixel.a = u.g;
	return pixel * color;
}
