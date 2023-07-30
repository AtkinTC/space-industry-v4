shader_type canvas_item;

uniform float radius = 32;
uniform vec2 position = vec2(0);

uniform vec2 gridWidth_1 = vec2(32, 32);
uniform float lineWidth_1 = 1.0;
uniform vec4 gridColor_1 = vec4(0.25);

uniform vec2 gridWidth_2 = vec2(128, 128);
uniform float lineWidth_2 = 3.0;
uniform vec4 gridColor_2 = vec4(0.5);

float grid(vec2 fragCoord, vec2 space, float gridWidth)
{
    vec2 p  = fragCoord - vec2(.5);
    vec2 size = vec2(gridWidth - .5);
    
    vec2 a1 = mod(p - size, space);
    vec2 a2 = mod(p + size, space);
    vec2 a = a2 - a1;
       
    float g = min(a.x, a.y);
    return clamp(-g, 0., 1.0);
}

void fragment() {
	vec2 tex_size = vec2(textureSize(TEXTURE, 0));
	vec2 local_coord = (UV-vec2(0.5)) * tex_size;
	vec2 coord = local_coord + position;
	float r = max(pow(pow(local_coord.x, 2) + pow(local_coord.y, 2), 0.5), 0.0);
	
	vec4 col = vec4(1.0);
	float a = grid(coord, gridWidth_1, lineWidth_1) + grid(coord, gridWidth_1, lineWidth_1);
	vec4 grid_1 = grid(coord, gridWidth_1, lineWidth_1) * gridColor_1;
	vec4 grid_2 = grid(coord, gridWidth_2, lineWidth_2) * gridColor_2;
	COLOR += grid_1 + grid_2;
}
