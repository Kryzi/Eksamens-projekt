extends Area2D

@export var BulletSpeed = 500
@export var damage = 1 
var direction: Vector2 = Vector2.DOWN #Standardretning	
@onready var player = get_node("/root/Main/Player")

func _physics_process(delta):
	position += direction * BulletSpeed * delta

func _on_body_entered(body: Node2D) -> void:
	
	if body.is_in_group("player") or body.is_in_group("Skjold"):
		body.hit_damage(damage)
		queue_free()
	elif body.is_in_group("obstacle"):
		queue_free()
