extends CharacterBody2D

@export var maxHealth: int = 20
var currentHealth: int
var speed: int = 25000
var player_state: String = "Idle"
var last_direction: Vector2 = Vector2.DOWN
var recoil_velocity: Vector2 

# Dash
var dashTime = 0.2
var dashing = false
var dashForce = 1200
var dash_velocity
var dashCD = 1.0
var canDash = true

@onready var HitSound = $"HitSound(mp3Cut_net)"
@onready var GedSlapSound = $GedSlapSound

func _ready():
	currentHealth = maxHealth
	PlayerInfo.health_data = {
		"current_health": currentHealth,
		"max_health": maxHealth,
	}

func _physics_process(delta):	
	var direction = Input.get_vector("Left", "Right", "Up", "Down")
	
	if direction == Vector2.ZERO:
		player_state = "Idle"
	else:
		player_state = "Walking"
		last_direction = direction.normalized()
	
	var input_velocity = direction * speed * delta
	
	var recoil_decay: float = 0.9
	
	if Input.is_action_just_pressed("Dash") and dashing == false and direction != Vector2(0,0) and canDash == true:
		dashing = true
		canDash = false
		
		player_state = "Dashing"
		play_anim(direction)
		
		dash_velocity = last_direction.normalized() * dashForce
		
		$Dashing.start(dashTime)
		$CanDashTime.start(dashCD)
	
	if dashing == true:
		velocity = dash_velocity
		dash_velocity *= 0.95
	else:
		velocity = input_velocity + recoil_velocity
		recoil_velocity *= recoil_decay
		play_anim(direction)
	move_and_slide()

func play_anim(dir):
	if player_state == "Idle":
		$AnimatedSprite2D.play("Idle " + Aimdirection(last_direction))
	elif player_state == "Walking":
		$AnimatedSprite2D.play("Walk " + Aimdirection(dir))
	elif player_state == "Dashing":
		$AnimatedSprite2D.play("Dash " + Aimdirection(dir))

func Aimdirection(dir: Vector2) -> String:
	if dir.y > 0:
		return "ned"
	elif dir.y < 0:
		return "op"
	elif dir.x > 0:
		return "højre"
	elif dir.x < 0:
		return "venstre"
	else:
		return Aimdirection(last_direction)

func hit_damage(damage):
	var new_health_data = {"current_health": PlayerInfo.health_data["current_health"] - damage}
	PlayerInfo.health_data = new_health_data
	get_node("/root/Main/HUD").apply_noise_shake()
	HitSound.play()
	
	if new_health_data["current_health"] <= 0:
		die()

func die():
	var invalid_high_score = 99999
	PlayerInfo.win_screen_reached.emit(false, invalid_high_score)

func _on_dashing_timeout() -> void:
	dashing = false

func _on_can_dash_time_timeout() -> void:
	canDash = true

func _on_damage_body_entered(body: Node2D) -> void:
	if body.name == "Gigaged":
		GedSlapSound.play()
		recoil_velocity = (global_position - body.global_position).normalized() * 2000
		hit_damage(1)

@onready var weapon = get_node("/root/Main/Player/Weapon")
func speedUpgrade(FirerateUpgrade):
	speed = speed * 1.15
	dashForce = dashForce * 1.15
	
	weapon.applyFirerateRangedUp(FirerateUpgrade)
	weapon.applyFirerateMeleeUp(FirerateUpgrade)
