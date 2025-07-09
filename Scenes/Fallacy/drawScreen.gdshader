shader_type canvas_item;

const vec2 screenSize = vec2(320, 200);
uniform float closerTo[320];

float remap(float value, float istart, float istop, float ostart, float ostop) {
    return ostart + (ostop - ostart) * ((value - istart) / (istop - istart));
}

void fragment() {
	vec2 coords = vec2(UV.x * 320.0, UV.y * 200.0);
	float distanceToWall = closerTo[int(coords.x)];
	float verticalProy = 16.0 / distanceToWall * 277.0;
	COLOR = vec4(0, 0, 0, 1.0);
	
	if (100.0 - (verticalProy/2.0) < coords.y && coords.y < 100.0 + (verticalProy/2.0)){
		float clr = remap(distanceToWall, 0.0, 120.0, 1.0, 0.0);
		COLOR = vec4(clr, clr, clr, 1.0);
	}
}

