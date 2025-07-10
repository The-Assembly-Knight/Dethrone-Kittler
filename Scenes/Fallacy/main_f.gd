extends Node2D
class_name MainF

@onready var player : Player = $player
@onready var screen : Sprite2D = $CanvasLayer/Screen

var rayList : Array[RayCast2D] = []

func get360Angle(deg : float) -> float:
	if deg > 360:
		deg -= 360
	if deg < 0:
		deg += 360
	return deg

#Se necesita una lista con un espacio Screen.x * 2
#Los primeros 320 datos son la distancia de la pared al jugador en ese pixel
#Los segundos 320 datos son la distancia del raycast que colisionó al borde de la pared
#Esto se usa para dibujar la textura
func _ready() -> void:
	setMaxDistance()

func _process(delta: float) -> void:
	pass

func sortEnemys(a : Node2D, b : Node2D) -> bool:
	if a.position.distance_squared_to(player.position) < b.position.distance_squared_to(player.position):
		return true
	return false

#Maxima distancia de visión con los raycast
func setMaxDistance() -> void:
	var mat : ShaderMaterial = screen.material
	mat.set_shader_parameter("maxDistance", player.maxDistance)

func giveInfoToShader() -> void:
	var mat : ShaderMaterial = screen.material
	var distanceList : Array[float] = []
	distanceList.resize(player.screenRes.x * 2)
	#Iterar sobre toda la lista de raycasts
	for i in player.screenRes.x:
		var ray : RayCast2D = rayList[i]
		#Extraer la rotación del raycast
		var angleRotation : float = deg_to_rad(remap(i, 0, rayList.size() - 1, player.FOV/-2, player.FOV/2))
		
		if ray.is_colliding():
			var collider : Node = ray.get_collider()
			#La distancia de la pared al jugador
			var distanceToPlayer : float = player.global_position.distance_to(ray.get_collision_point())
			#Se añade a la lista
			#La multiplicación por el coseno del angulo es para corregir el efecto de ojo de pez
			distanceList[i] = distanceToPlayer * cos(angleRotation)
			#Aquí se settean los datos para la textura, si el raycast colisiona
			#con una pared en vertical, se usa el punto de colisión en y % 64
			#con una pared en horizontal, se usa el punto de colisión en x % 64 
			#el % es una operación llamada modulo (Busquenla si no saben que hace) 
			if ray.get_collision_normal().y != 0.0:
				distanceList[i + player.screenRes.x] = fmod(ray.get_collision_point().x, 16.0)
			else:
				distanceList[i + player.screenRes.x] = fmod(ray.get_collision_point().y, 16.0)
			
		#Si el raycast no colisiona, la distancia hacia esa "pared" es la maxima posible
		else:
			distanceList[i] = player.maxDistance
	
	#Pasar la información al shader
	mat.set_shader_parameter("distanceToW", distanceList)
	
	#Array con todos los enemigos sorteado por distancia al jugador
	var enemys : Array = get_tree().get_nodes_in_group("enemyPos")
	enemys.sort_custom(sortEnemys)
	
	#Vector que representa el angulo 0 del FOV
	var initFOVvec : Vector2 = Vector2.from_angle(deg_to_rad(player.rotation_degrees - (player.FOV/2)))
	#Arrays para pasar información al Shader
	var indexEnemy : Array = []; indexEnemy.resize(16)
	var centerEnemy : Array = []; centerEnemy.resize(16)
	var distanceEnemy : Array = []; distanceEnemy.resize(16)
	for i in enemys.size():
		#Maximo 16 sprites activos a la vez
		if i >= 16: break
		#Tomar el sprite del enemigo
		indexEnemy[i] = enemys[i].textureIndex
		#Calcular el centro del enemigo relativo al FOV del jugador
		var vecToEnemy : Vector2 = player.position.direction_to(enemys[i].position)
		var angleToEnemy : float = rad_to_deg(initFOVvec.angle_to(vecToEnemy))
		centerEnemy[i] = floor(angleToEnemy*320/60)
		#Calcular la distancia del jugador al enemigo
		distanceEnemy[i] = enemys[i].position.distance_to(player.position)
	
	#Enviar la información
	mat.set_shader_parameter("indexEnemy", indexEnemy)
	mat.set_shader_parameter("centerEnemy", centerEnemy)
	mat.set_shader_parameter("distanceEnemy", distanceEnemy)
	
	mat.set_shader_parameter("playerPosition", player.position)
	mat.set_shader_parameter("playerVelocity", player.velocity)
