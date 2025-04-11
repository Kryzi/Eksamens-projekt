extends Area2D

@export var BulletSpeed = 500
@export var damage = 1 
var direction: Vector2 = Vector2.DOWN
var targetPos: Vector2  = Vector2.DOWN

@onready var player = get_node("/root/Main/Player")

func _ready() -> void:
	targetPos = player.global_position
	direction = (targetPos - global_position).normalized()
	


func _physics_process(delta):
	position += direction * BulletSpeed * delta

func _on_body_entered(body: Node2D) -> void:
	
	if body.is_in_group("player") or body.is_in_group("Skjold"):
		body.hit_damage(damage)
		queue_free()
	elif body.is_in_group("obstacle"):
		queue_free()




#var speed = 100
#var direction = Vector2.RIGHT

#func _physics_process(delta: float) -> void:
#	position += direction * speed * delta
	


#func _on_screen_exited() -> void:
#	queue_free()
	
