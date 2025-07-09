extends CharacterBody2D
class_name Player

const screenRes : Vector2 = Vector2(320, 200)

@export var maxDistance : int = 100
@export var FOV : int = 60
@export var movSpeed : float = 60
@export var rotationSpeed : float = 60

func generateRaycasts() -> void:
	for i in range(screenRes.x):
		var ray : RayCast2D = RayCast2D.new()
		var radAngle : float = deg_to_rad(remap(i, 0, screenRes.x - 1, -FOV/2, FOV/2))
		ray.target_position = Vector2(maxDistance, 0).rotated(radAngle)
		get_parent().rayList.append(ray)
		add_child(ray)

func _ready():
	generateRaycasts()

func _process(delta: float):
	var dirMov : float = Input.get_axis("fall_s", "fall_w")
	velocity = (dirMov * movSpeed) * Vector2.from_angle(rotation)
	var dirRot : float = Input.get_axis("fall_a", "fall_d")
	rotation_degrees += rotationSpeed * dirRot * delta
	get_parent().giveInfoToShader()
	move_and_slide()
