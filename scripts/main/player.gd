
extends CharacterBody2D

@export var maxHealth: int = 20
var currentHealth: int
var speed: int = 50000 # speed in pixels/sec
var player_state: String = "Idle"
var last_direction: Vector2 = Vector2.DOWN  # Standardretning
var recoil_velocity: Vector2 

# Dash
var dashCD = 1.0 
var dashing = false
var dashForce = 1000

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
		last_direction = direction.normalized()  # Husk sidste retning
	
	var input_velocity = direction * speed * delta
	
	var recoil_decay: float = 0.9
	print(direction)
	
	if Input.is_action_just_pressed("Dash") and dashing == false and direction != Vector2(0,0):
		dashing = true
		recoil_velocity = last_direction * dashForce
		
		await get_tree().create_timer(dashCD).timeout
		dashing = false
	
	
	velocity = input_velocity + recoil_velocity
	recoil_velocity *= recoil_decay
	
	move_and_slide()
	play_anim(direction)
	

func play_anim(dir):
	if player_state == "Idle":
		#print("Idle animation:", Aimdirection(last_direction))  # Debugging
		$AnimatedSprite2D.play("Idle " + Aimdirection(last_direction))
	elif player_state == "Walking":
		#print("Walking animation:", Aimdirection(dir))  # Debugging
		$AnimatedSprite2D.play("Walk " + Aimdirection(dir))

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
		return Aimdirection(last_direction)  # Brug sidste kendte retning


func hit_damage(damage):
	# Brug variabler fra PlayerInfo, så sender den automatisk et signal til HUD
	var new_health_data = {"current_health": PlayerInfo.health_data["current_health"] - damage}
	PlayerInfo.health_data = new_health_data
	get_node("/root/Main/HUD").apply_noise_shake()
	
	if new_health_data["current_health"] <= 0:
		die()

func die():
	var highScore = PlayerInfo.current_coins
	PlayerInfo.win_screen_reached.emit(false, highScore)
