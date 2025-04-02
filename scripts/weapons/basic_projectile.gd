extends Area2D

@export var BulletSpeed: int = 750
var Damage: int = 1 
var targetPos: Vector2
var direction: Vector2

func _ready() -> void:
	direction = (targetPos - global_position).normalized()

func _physics_process(delta):
	position += direction * BulletSpeed * delta

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		body.hit_damage(Damage)
		queue_free()
	elif not body.is_in_group("player"):
		queue_free()
	
	
