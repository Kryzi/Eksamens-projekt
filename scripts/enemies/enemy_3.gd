extends CharacterBody2D

var speed = 10000
var health = 15
var last_direction: Vector2 = Vector2.DOWN
var player_in_attack_range = false  # Holder styr på, om spilleren er tæt nok på til angreb

@onready var player = get_node("/root/Main/Player")
@onready var controller = get_node("/root/Main/MapController/Spawner")
@onready var animated_sprite = $AnimatedSprite2D
#@onready var attack_area = $AttackArea  # Area2D der registrerer, om spilleren er i skud-rækkevidde

@export var bullet_scene: PackedScene
@export var coin_scene: PackedScene

func _ready() -> void:
	$AnimatedSprite2D.play("Idle")

func die():
	dropCoin()
	queue_free()
	controller.checkDeath()

func dropCoin():
	var coin_instance = coin_scene.instantiate()
	coin_instance.global_position = global_position
	get_tree().get_root().call_deferred("add_child", coin_instance)

func hit_damage(damage):
	health -= damage
	if health <= 0:
		die()

func shoot():
	if player_in_attack_range:
		var direction_to_player = (player.global_position - global_position).normalized()
		
		var left_offset = direction_to_player.rotated(deg_to_rad(45))
		var right_offset = direction_to_player.rotated(deg_to_rad(-45))
		
		$AnimatedSprite2D.play("Charge")
		await $AnimatedSprite2D.animation_finished
		
		$AnimatedSprite2D.play("Attack")
		
		# Første bullet (45 grader venstre)
		var bullet_instance1 = bullet_scene.instantiate()
		bullet_instance1.global_position = $ShootingPoint.global_position
		bullet_instance1.direction = left_offset  # Sæt direction direkte
		get_tree().get_root().call_deferred("add_child", bullet_instance1)
		
		# Anden bullet (45 grader højre)
		var bullet_instance2 = bullet_scene.instantiate()
		bullet_instance2.global_position = $ShootingPoint.global_position
		bullet_instance2.direction = right_offset  # Sæt direction direkte
		get_tree().get_root().call_deferred("add_child", bullet_instance2)
		
		await $AnimatedSprite2D.animation_finished
		$AnimatedSprite2D.play("Idle")




func _on_attack_timer_timeout() -> void:
	if player_in_attack_range:  # Kun skyd, hvis spilleren er inden for rækkevidde
		shoot()
		

func _on_view_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"): 
		player_in_attack_range = true

func _on_view_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_attack_range = false
