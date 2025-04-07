extends Area2D

@export var BulletSpeed: int = 750
@export var turnSpeed: float = 10.0  # Hvor hurtigt skuddet drejer mod målet
var Damage: int = 1 
var targetPos: Vector2
var direction: Vector2
var screen_shake = 0.0


func _ready() -> void:
	direction = (targetPos - global_position).normalized()
	$FireParticle.emitting = true

func _physics_process(delta):
	
	# Opdater målpositionen dynamisk
	targetPos = get_global_mouse_position()
	
	# Beregn en ny retning, der gradvist justerer sig mod musens position
	var new_direction = (targetPos - global_position).normalized()
	direction = direction.lerp(new_direction, turnSpeed * delta).normalized()
	
	
	
	# Bevæger sig i den nye retning
	position += direction * BulletSpeed * delta
	
	scale += Vector2(0.01, 0.01)
	var particleOffset = 20
	if particleOffset < 51:
		particleOffset += 1
	
	rotation = direction.angle() + PI
	
	$FireParticle.global_position = global_position - (direction * particleOffset)  # Flyt partiklen bagud
	
	if BulletSpeed == 375:
		$FireParticle.texture = load("res://sprites/vaaben/partikler/ild/ild_partikel-2.png")
	
	if BulletSpeed > 125:
		BulletSpeed -= 1
	if BulletSpeed == 125:
		$FireParticle.initial_velocity_min = 40
		$FireParticle.initial_velocity_max = 75
		BulletSpeed = 124
	else:
		$FireParticle.scale_amount_min += 0.01
		$FireParticle.scale_amount_max += 0.01
	
	if BulletSpeed == 124:
		screen_shake += 0.05
		print(screen_shake)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		body.hit_damage(Damage)
		
		get_node("/root/Main/HUD").NOISE_SHAKE_STRENGTH = screen_shake
		get_node("/root/Main/HUD").apply_noise_shake()
		get_node("/root/Main/HUD").NOISE_SHAKE_STRENGTH = 15.0
		
		queue_free()
	elif not body.is_in_group("player"):
		get_node("/root/Main/HUD").NOISE_SHAKE_STRENGTH = screen_shake
		get_node("/root/Main/HUD").apply_noise_shake()
		get_node("/root/Main/HUD").NOISE_SHAKE_STRENGTH = 15.0
		
		queue_free()


func _on_damage_multipler_timer_timeout() -> void:
	Damage += 1
