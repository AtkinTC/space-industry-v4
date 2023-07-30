shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

uniform vec4 outline_color : source_color = vec4(.17,1.0,.36,0.5);
uniform vec4 inner_color : source_color = vec4(.17,1.0,.36,0.1);

void fragment() {
	vec4 color = texture(SCREEN_TEXTURE, SCREEN_UV);
	if (color.r < 1.0 && color.r > 0.0) {
		COLOR = outline_color;
	} else if (color.r == 1.0) {
		COLOR = inner_color;
	} else { 
		COLOR = vec4(0.0);
	}
}