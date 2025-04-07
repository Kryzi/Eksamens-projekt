extends Area2D

@export var BulletSpeed: int = 750
var Damage: int = 1 
var targetPos: Vector2
var direction: Vector2

@export var IceParticle: PackedScene


func _ready() -> void:
	direction = (targetPos - global_position).normalized()

func _physics_process(delta):
	position += direction * BulletSpeed * delta

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		body.hit_damage(Damage)
		emitParticle()
		queue_free()
	elif not body.is_in_group("player"):
		emitParticle()
		queue_free()
	
	

func emitParticle():
	var particle = IceParticle.instantiate()
	
	get_tree().get_root().call_deferred("add_child", particle)
	particle.global_position = global_position
	particle.emitting = true
