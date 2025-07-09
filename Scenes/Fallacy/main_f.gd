extends Node2D
class_name MainF

@onready var player : Player = $player
var drawingDistance : float = 0
@onready var screen : Sprite2D = $CanvasLayer/Screen

var rayList : Array[RayCast2D] = []
var closerList : Array[float] = []

func _ready():
	drawingDistance = pow(player.maxDistance, 2)
	closerList.resize(player.screenRes.x)

func _process(delta: float):
	pass

func giveInfoToShader() -> void:
	for i in rayList.size():
		var ray : RayCast2D = rayList[i]
		var angleRotation : float = deg_to_rad(remap(i, 0, rayList.size() - 1, player.FOV/-2, player.FOV/2))
		if ray.is_colliding():
			var distanceToPlayer : float = player.global_position.distance_to(ray.get_collision_point())
			closerList[i] = distanceToPlayer * cos(angleRotation)
		else:
			closerList[i] = 120.0
	
	var mat : ShaderMaterial = screen.material
	mat.set_shader_parameter("closerTo", closerList)
