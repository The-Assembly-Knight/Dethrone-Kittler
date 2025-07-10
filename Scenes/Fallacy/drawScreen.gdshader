shader_type canvas_item;

//Tamaño de viewport
const vec2 screenSize = vec2(320, 200);
//La textura de la pared
uniform sampler2D bitmap;
//La textura del suelo
uniform sampler2D floorBitmap;

//Array con las texturas de los enemigos
uniform sampler2D bitmap_enemy[16];

//El array con los datos de distancia y offset para textura
uniform float distanceToW[320 * 2];
//La maxima distancia posible
uniform float maxDistance = 100.0;

//Array con los indices de texuturas, centro relativos y distancias hacia el jugador
uniform float indexEnemy[16];
uniform float centerEnemy[16];
uniform float distanceEnemy[16];

//Mi implementación de la función remap (está explicada en la documentación oficial de Godot)
float remap(float value, float istart, float istop, float ostart, float ostop) {
    return ostart + (ostop - ostart) * ((value - istart) / (istop - istart));
}

vec4 drawFloor(vec2 uv){
	vec4 color1 = mix(vec4(0.1, 0.1, 0.8, 1.0), vec4(0, 0, 0, 1.0), smoothstep(0.0, 0.5, uv.y));
	vec4 color2 = mix(vec4(0.1, 0.1, 0.3, 1.0), vec4(0, 0, 0, 1.0), smoothstep(1.0, 0.5, uv.y));
	return mix(color1, color2, step(0.5, uv.y));
}

vec4 drawSprite(int i, vec2 coords, vec4 color, float halfVertProyEnemy){
	//Si el las coordenadas del pixel están entre el rango de la altura del enemigo
	if (100.0 - halfVertProyEnemy < coords.y && coords.y < 100.0 + halfVertProyEnemy){
		float textureX = remap(coords.x, centerEnemy[i] - halfVertProyEnemy, centerEnemy[i] + halfVertProyEnemy, 0, 1.0);
		//Convertir la altura de la pared en coordenadas UV
		float textureY = remap(coords.y, 100.0 - halfVertProyEnemy, 100.0 + halfVertProyEnemy, 0, 1.0);
		//Extraer el color correspondiente de la textura
		vec4 col = texture(bitmap_enemy[int(indexEnemy[i])], vec2(textureX, textureY));
		col.rgb = mix(col.rgb, vec3(0.0, 0.0, 0.0), remap(distanceEnemy[i], 0, maxDistance, 0, 1.0));
		return mix(color, col, col.a);
	}
	return color;
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
	float verticalProyWall = 16.0 / distanceToWall * 277.0;
	//Si ninguna de las condiciones abajo se cumple, dibuja el suelo
	COLOR = drawFloor(UV);

	//Si el las coordenadas del pixel están entre el rango de la altura de la pared
	if (100.0 - (verticalProyWall/2.0) < coords.y && coords.y < 100.0 + (verticalProyWall/2.0)){
		//Convertir el offset de la textura en coordenadas UV
		float textureX = modCoord/16.0;
		//Convertir la altura de la pared en coordenadas UV
		float textureY = remap(coords.y, 100.0 - (verticalProyWall/2.0), 100.0 + (verticalProyWall/2.0), 0, 1.0);
		vec2 texVec = vec2(textureX, textureY);
		//Extraer el color correspondiente de la textura
		COLOR = mix(texture(bitmap, texVec), vec4(0.0, 0.0, 0.0, 1.0), remap(distanceToWall, 0, maxDistance, 0, 1.0));
	}

	for (int i = 15; i >= 0; i--){
		float verticalProyEnemy = 16.0 / distanceEnemy[i] * 277.0;
		float halfVertProyEnemy = (verticalProyEnemy/2.0);
		if (centerEnemy[i] - halfVertProyEnemy < coords.x && coords.x < centerEnemy[i] + halfVertProyEnemy){
			if (distanceToWall > distanceEnemy[i]){
				COLOR = drawSprite(i, coords, COLOR, halfVertProyEnemy);
			}
		}
	}
}
