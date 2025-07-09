shader_type canvas_item;

const vec2 screenSize = vec2(320, 200);
uniform vec4 colors[320];

void fragment() {
	int coords = int(UV.x * 320.0);
	COLOR = colors[coords];
}

