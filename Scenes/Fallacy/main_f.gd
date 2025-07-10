extends Node2D
class_name MainF

@onready var player : Player = $player
@onready var screen : Sprite2D = $CanvasLayer/Screen

var rayList : Array[RayCast2D] = []
var distanceList : Array[float] = []

#Se necesita una lista con un espacio Screen.x * 2
#Los primeros 320 datos son la distancia de la pared al jugador en ese pixel
#Los segundos 320 datos son la distancia del raycast que colisionó al borde de la pared
#Esto se usa para dibujar la textura
func _ready() -> void:
	distanceList.resize(player.screenRes.x * 2)
	setMaxDistance()

func _process(delta: float) -> void:
	pass

#Maxima distancia de visión con los raycast
func setMaxDistance() -> void:
	var mat : ShaderMaterial = screen.material
	mat.set_shader_parameter("maxDistance", player.maxDistance)

func giveInfoToShader() -> void:
	var rayHitType : Array[int]
	rayHitType.resize(player.screenRes.x)
	
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
				distanceList[i + player.screenRes.x] = fmod(ray.get_collision_point().x, 64.0)
			else:
				distanceList[i + player.screenRes.x] = fmod(ray.get_collision_point().y, 64.0)
			
			if collider.is_in_group("enemy"):
				rayHitType[i] = 1
			else:
				rayHitType[i] = 0
		#Si el raycast no colisiona, la distancia hacia esa "pared" es la maxima posible
		else:
			distanceList[i] = player.maxDistance
	
	#Pasar la información al shader
	var mat : ShaderMaterial = screen.material
	mat.set_shader_parameter("distanceToW", distanceList)
	mat.set_shader_parameter("rayHitType", rayHitType)
