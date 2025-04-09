extends CharacterBody2D

var speed = 100.0
var health = 60
var is_charging = false
var can_attack = true
var player_in_range = false
var patrol_direction = Vector2.RIGHT
var charge_target_position = Vector2.ZERO
var has_hit_player = false

@export var charge_speed = 400.0
@export var patrol_wait_time = 1.0
@export var damage = 2
@export var max_charge_time = 1.25  # hvor længe den charger

@onready var player = get_node("/root/Main/Player")
@onready var sprite = $AnimatedSprite2D
@onready var hitbox = $Hitbox
@onready var spawner = get_node("/root/Main/MapController/Spawner")
@onready var raycast = $WallDetector
@onready var raycast2 = $WallDetector2
@onready var raycast3 = $WallDetector3

func _physics_process(delta):
	if is_charging:
		var dir = (charge_target_position - global_position).normalized()
		velocity = dir * charge_speed
		sprite.play("Charge " + direction_name(dir))
		move_and_slide()

		# MANUEL COLLISION CHECK:
		if not has_hit_player:
			for body in hitbox.get_overlapping_bodies():
				if body.name == "Player":
					body.hit_damage(damage)
					has_hit_player = true
					end_charge()
		return

	# Start charge hvis spiller er synlig og vi må angribe
	if player_in_range and can_attack:
		start_charge()
		return

	# Patruljér
	if raycast.is_colliding() or raycast2.is_colliding() or raycast3.is_colliding():
		patrol_direction *= -1
		raycast.target_position *= -1
		raycast2.target_position *= -1
		raycast3.target_position *= -1

	velocity = patrol_direction * speed
	sprite.play("Walk " + direction_name(patrol_direction))
	move_and_slide()

func start_charge():
	is_charging = true
	can_attack = false
	has_hit_player = false
	charge_target_position = player.global_position
	call_deferred("_start_charge_timeout")

func _start_charge_timeout():
	await get_tree().create_timer(max_charge_time).timeout
	if is_charging:
		end_charge()

func end_charge():
	is_charging = false
	velocity = Vector2.ZERO
	sprite.play("Idle " + direction_name(patrol_direction))
	await get_tree().create_timer(1.0).timeout
	can_attack = true

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

func _on_hitbox_body_entered(body: Node2D) -> void:
	# Ekstra sikkerhed – bruges ikke længere som eneste metode
	if body.name == "Player" and is_charging and not has_hit_player:
		body.hit_damage(damage)
		has_hit_player = true
		end_charge()

func _on_view_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = true

func _on_view_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = false
