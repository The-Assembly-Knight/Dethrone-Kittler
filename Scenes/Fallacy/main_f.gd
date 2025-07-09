extends Node2D
class_name MainF

@onready var player : Player = $player
var drawingDistance : float = 0
@onready var screen : Sprite2D = $CanvasLayer/Screen

var rayList : Array[RayCast2D] = []
var closerList : Array[Color] = []

func _ready():
	drawingDistance = pow(player.maxDistance, 2)
	closerList.resize(player.screenRes.x)

func _process(delta: float):
	pass

func giveInfoToShader() -> void:
	for i in rayList.size():
		var ray : RayCast2D = rayList[i]
		if ray.is_colliding():
			var distanceToPlayer : float = player.global_position.distance_squared_to(ray.get_collision_point())
			var remapedValue : int = remap(distanceToPlayer, 0, drawingDistance, 255, 0)
			closerList[i] = Color8(remapedValue, remapedValue, remapedValue)
		else:
			closerList[i] = Color.BLACK
	
	var mat : ShaderMaterial = screen.material
	mat.set_shader_parameter("colors", closerList)
