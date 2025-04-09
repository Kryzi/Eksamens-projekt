extends CharacterBody2D

var speed = 5000
var health = 15
var last_direction: Vector2 = Vector2.DOWN
var player_in_attack_range = false  # Holder styr på, om spilleren er tæt nok på til angreb

@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var player = get_node("/root/Main/Player")
var Enemy_state: String = "Walking"
@onready var controller = get_node("/root/Main/MapController/Spawner")
@onready var animated_sprite = $AnimatedSprite2D
#@onready var attack_area = $AttackArea  # Area2D der registrerer, om spilleren er i skud-rækkevidde
@onready var ShootSound = $Enemy1Sound
var attacking = false

@export var bullet_scene: PackedScene
@export var coin_scene: PackedScene
@export var timeBetweenBullets: float = 0.05
@export var bulletsCount: int = 50
@export var vinkelPerSkud: float = 20

func _ready() -> void:
	$AnimatedSprite2D.play("Idle")

func die():
	dropCoin()
	queue_free()
	controller.checkDeath()

func _physics_process(delta: float) -> void:
	if not player_in_attack_range and attacking == false:
		var dir = to_local(nav_agent.get_next_path_position()).normalized()

		# Opdater Enemy_state baseret på bevægelse
		if dir.length() > 0:
			Enemy_state = "Walking"
			last_direction = dir
		else:
			Enemy_state = "Idle"

		velocity = dir * speed * delta
		play_anim(dir)  # Opdater animation baseret på retning
		
		move_and_slide()
	else:
		Enemy_state = "Idle"  # Stå stille mens den skyder
		velocity = Vector2.ZERO

func play_anim(dir):
	if Enemy_state == "Idle":
		animated_sprite.play("Idle")
	elif Enemy_state == "Walking":
		animated_sprite.play("Walk")

func dropCoin():
	var coin_instance = coin_scene.instantiate()
	coin_instance.global_position = global_position
	get_tree().get_root().call_deferred("add_child", coin_instance)

func hit_damage(damage):
	health -= damage
	$AnimatedSprite2D/AnimationPlayer.play("Hurt")
	if health <= 0:
		die()

func shoot():
	if player_in_attack_range:
		
		$AnimatedSprite2D.play("Angreb")
		var direction_to_player = (player.global_position - global_position).normalized()
		attacking = true
		ShootSound.play()
		
		for i in bulletsCount:
			var offset = direction_to_player.rotated(deg_to_rad(vinkelPerSkud * i))
			spawnBullet(offset)
			await get_tree().create_timer(timeBetweenBullets).timeout
		
		
		attacking = false

func spawnBullet(offset):
	var bullet_instance = bullet_scene.instantiate()
	bullet_instance.get_child(0).texture = load("res://sprites/fjender/projektiler/musik-projektil.png")
	bullet_instance.global_position = $ShootingPoint.global_position
	bullet_instance.direction = offset  # Sæt direction direkte
	get_tree().get_root().call_deferred("add_child", bullet_instance)



func _on_attack_timer_timeout() -> void:
	if player_in_attack_range:  # Kun skyd, hvis spilleren er inden for rækkevidde
		shoot()
		

func make_path() -> void:
	nav_agent.target_position = player.global_position  # Altid gå mod spilleren

func _on_move_timer_timeout():
	make_path()

func _on_view_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"): 
		player_in_attack_range = true

func _on_view_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_attack_range = false
