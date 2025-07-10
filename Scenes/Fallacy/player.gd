extends CharacterBody2D
class_name Player

const screenRes : Vector2 = Vector2(320, 200)

##Distancia maxima de vista, cualquier cosa más allá, será dibujada negra
@export var maxDistance : int = 100
##Angulo de vista, habitualmente el angulo de vista humano se encuentra entre 45 y 60 grados
@export var FOV : int = 60
##Velocidad de movimiento en pixeles por segundo
@export var movSpeed : float = 60
##Velocidad de giro en grados por segundo
@export var rotationSpeed : float = 60

#Bastante explicativa por si sola, genera todos los raycasts
#Los genera en un rango de -FOV/2 a FOV/2, por ejemplo, si FOV = 60 grados
#Entonces los raycasts iran de -30 a 30 grados
func generateRaycasts() -> void:
	for i in range(screenRes.x):
		var ray : RayCast2D = RayCast2D.new()
		ray.collide_with_areas = true
		ray.collide_with_bodies = true
		var radAngle : float = deg_to_rad(remap(i, 0, screenRes.x - 1, -FOV/2, FOV/2))
		ray.target_position = Vector2(maxDistance, 0).rotated(radAngle)
		get_parent().rayList.append(ray)
		add_child(ray)

func _ready() -> void:
	generateRaycasts()

#Control de movimiento y giro
func _process(delta: float) -> void:
	var dirMov : float = Input.get_axis("fall_s", "fall_w")
	velocity = (dirMov * movSpeed) * Vector2.from_angle(rotation)
	var dirRot : float = Input.get_axis("fall_a", "fall_d")
	rotation_degrees += rotationSpeed * dirRot * delta
	var steerMov : float = Input.get_axis("fall_f", "fall_h")
	if steerMov != 0:
		velocity = movSpeed * Vector2.from_angle(rotation + deg_to_rad(steerMov * 90))
	get_parent().giveInfoToShader()
	move_and_slide()
