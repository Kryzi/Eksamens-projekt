extends Area2D

@export var BulletSpeed: int = 750
@export var zigzag_amplitude: float = 5.0  # How wide the zig-zag is
@export var zigzag_frequency: float = 20.0  # How fast the zig-zag moves
@export var waterParticle: PackedScene
@export var vand_partikel_1_texture: Texture2D
@export var vand_partikel_2_texture: Texture2D
@export var vand_partikel_3_texture: Texture2D

var Damage: int = 1 
var targetPos: Vector2
var direction: Vector2
var sideways_direction: Vector2
var time: float = 0.0


func _ready() -> void:
	direction = (targetPos - global_position).normalized()
	sideways_direction = Vector2(-direction.y, direction.x)  # Perpendicular to movement

func _physics_process(delta):
	time += delta
	var zigzag_offset = sideways_direction * sin(time * zigzag_frequency) * zigzag_amplitude
	position += (direction * BulletSpeed * delta) + zigzag_offset

func _on_body_entered(body: Node2D) -> void:
	
	if body.is_in_group("enemy"):
		emitParticle()
		
		body.hit_damage(Damage)
		queue_free()
	elif not body.is_in_group("player"):
		emitParticle()
		
		queue_free()

func emitParticle():
	var particle = waterParticle.instantiate()
	
	var i = randi_range(0, 2)
	if i == 0:
		particle.texture = vand_partikel_1_texture
	elif i == 1:
		particle.texture = vand_partikel_2_texture
	elif i == 2:
		particle.texture = vand_partikel_3_texture
	
	
	get_tree().get_root().call_deferred("add_child", particle)
	particle.global_position = global_position
	particle.emitting = true
