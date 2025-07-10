shader_type canvas_item;

//Tamaño de viewport
const vec2 screenSize = vec2(320, 200);
//La textura de la pared
uniform sampler2D bitmap;

// No pude encontrar donde inicializaste el bitmap de las paredes asi q cree otro xdxdxdxd
// Lo logre encontrar, pero no voy ponerlo en el bitmap con un offset porq me da pereza son las 2:23am
uniform sampler2D bitmap_enemy;

//El array con los datos de distancia y offset para textura
uniform float distanceToW[320 * 2];
//La maxima distancia posible
uniform float maxDistance = 100.0;

uniform int rayHitType[320];

//Mi implementación de la función remap (está explicada en la documentación oficial de Godot
float remap(float value, float istart, float istop, float ostart, float ostop) {
    return ostart + (ostop - ostart) * ((value - istart) / (istop - istart));
}

void fragment() {
	//Convertir las coordenadas UV en coordenadas de pantalla
	vec2 coords = vec2(UV.x * 320.0, UV.y * 200.0);
	//Encontrar la distancia del jugador a la pared que le corresponde al pixel
	float distanceToWall = distanceToW[int(coords.x)];
	//Encontrar el offset que le corresponde al pixel para la textura
	float modCoord = distanceToW[int(coords.x) + 320];
	//Esto se usa para hallar la proyección vertical de la pared, concretamente su altura
	//Esto es lo que hace que, mientras más cerca, más grande y mientras más lejos, más pequeño
	float verticalProy = 16.0 / distanceToWall * 277.0;
	//Si ninguna de las condiciones abajo se cumple, simplemente se queda negro
	COLOR = vec4(0, 0, 0, 1.0);
	
	//Si el las coordenadas del pixel están entre el rango de la altura de la pared
	if (100.0 - (verticalProy/2.0) < coords.y && coords.y < 100.0 + (verticalProy/2.0)){
		//Convertir el offset de la textura en coordenadas UV
		float textureX = modCoord/64.0;
		//Convertir la altura de la pared en coordenadas UV
		float textureY = remap(coords.y, 100.0 - (verticalProy/2.0), 100.0 + (verticalProy/2.0), 0, 1.0);
		vec2 texVec = vec2(textureX, textureY);
		//Extraer el color correspondiente de la textura
        if (rayHitType[int(coords.x)] == 1) {
            COLOR = texture(bitmap_enemy, texVec);
        } else {
            COLOR = texture(bitmap, texVec);
        }
		
	}
}

