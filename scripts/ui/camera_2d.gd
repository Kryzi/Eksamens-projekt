extends Camera2D

@export var SMOOTH_SPEED: float = 3.0
@export var LIMIT_LEFT: float = -150
@export var LIMIT_RIGHT: float = 150
@export var LIMIT_TOP: float = -100
@export var LIMIT_BOTTOM: float = 100

func _process(delta: float) -> void:
	cameraUpdate(delta)

func cameraUpdate(delta: float):
	var target_pos = get_local_mouse_position()
	
	target_pos.x = clamp(target_pos.x, LIMIT_LEFT, LIMIT_RIGHT)
	target_pos.y = clamp(target_pos.y, LIMIT_TOP, LIMIT_BOTTOM)

	position = lerp(position, target_pos, SMOOTH_SPEED * delta)
