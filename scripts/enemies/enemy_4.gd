extends CharacterBody2D

var speed = 100.0
var health = 60
var player_in_range = false
var is_charging = false
var last_direction = Vector2.DOWN
var thinking = false
var patrol_direction = Vector2.RIGHT  # Startretning
var charge_target_position = Vector2.ZERO
var has_damaged_player = false  # Undgå at skade flere gange

@export var charge_speed = 400.0
@export var patrol_wait_time = 1.0
@export var damage = 2

@onready var player = get_node("/root/Main/Player")
@onready var sprite = $AnimatedSprite2D
@onready var hitbox = $Hitbox
@onready var spawner = get_node("/root/Main/MapController/Spawner")
@onready var raycast = $WallDetector

func _physics_process(delta):
	# Hvis fjenden er i ladningstilstand, bevæg mod spilleren
	if is_charging:
		var dir = (charge_target_position - global_position).normalized()
		velocity = dir * charge_speed
		sprite.play("Charge " + direction_name(dir))
		move_and_slide()
		
		var distance = global_position.distance_to(charge_target_position)
		
		if distance < 10:
			$View.monitoring = false
			is_charging = false
			await get_tree().create_timer(1.0).timeout
			$View.monitoring = true
		return

	# Hvis spilleren er inden for rækkevidde og ikke allerede lader op, start ladning
	if player_in_range and not is_charging:
		is_charging = true
		charge_target_position = player.global_position
		has_damaged_player = false
		return

	# Patruljér i en retning og vend, hvis væg detekteres
	if raycast.is_colliding():
		patrol_direction *= -1
		raycast.target_position *= -1

	velocity = patrol_direction * speed
	sprite.play("Walk " + direction_name(patrol_direction))
	move_and_slide()

func direction_name(dir: Vector2) -> String:
	if abs(dir.x) > abs(dir.y):
		return "højre" if dir.x > 0 else "venstre"
	else:
		return "ned" if dir.y > 0 else "op"

func hit_damage(amount):
	health -= amount
	if health <= 0:
		die()

func die():
	var coin = preload("res://scenes/collectables/coin.tscn").instantiate()
	coin.global_position = global_position
	get_tree().get_root().add_child(coin)
	spawner.checkDeath()
	queue_free()

# Når hitboxen rammer spilleren under ladning, stop ladning og fortsæt patruljeringen
func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.name == "Player" and is_charging and not has_damaged_player:
		body.hit_damage(damage)
		has_damaged_player = true
		is_charging = false  # Stop efter skaden
		# Fortsæt patruljeringen selv efter skaden
		# Fjenden skal fortsætte med at patruljere, uanset hvad
		return

# Når fjenden ser spilleren, skal den begynde at lade op
func _on_view_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = true
		# Hvis fjenden allerede er i ladning, skal den fortsætte
		if not is_charging:
			is_charging = true
			charge_target_position = player.global_position

# Når spilleren forlader synsvidde, stop ladning og fortsæt patruljeringen
func _on_view_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = false
		if is_charging:
			is_charging = false  # Stop ladning, hvis spilleren ikke er i nærheden
