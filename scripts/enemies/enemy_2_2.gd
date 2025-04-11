extends CharacterBody2D

var speed = 17500
var health = 20
var theta: float = 0.0
var Enemy_state: String = "Walking"
var player_in_attack_range = false
var last_shot_time = 0.0

@onready var shoot_interval = $attack_Timer.wait_time
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var player = get_node("/root/Main/Player")
@onready var controller = get_node("/root/Main/MapController/Spawner")
@onready var animated_sprite = $AnimatedSprite2D
@onready var attack_area = $View
@onready var ShootSound = $Enemy2Sound

@export_range(0, 2 * PI) var alpha: float = 0.0

@export var bullet_scene: PackedScene
@export var coin_scene: PackedScene
@export var coinNum: int

func get_vector(angle):
	theta = angle + alpha
	return Vector2(cos(theta), sin(theta))

func shoot(angle):
	if player_in_attack_range:
		animated_sprite.play("Charge")
		
		await animated_sprite.animation_finished
		animated_sprite.play("Angreb")
		ShootSound.play()
		
		var num_bullets = 24
		for i in range(num_bullets):
			var bullet_instance = bullet_scene.instantiate()
			bullet_instance.position = global_position
			var bullet_angle = angle + (i * 2 * PI / num_bullets) #Spred kuglerne ud i en cirkel
			bullet_instance.direction = get_vector(bullet_angle)
			get_tree().get_root().call_deferred("add_child", bullet_instance)

func _physics_process(delta) -> void:
	if not player_in_attack_range:
		var dir = to_local(nav_agent.get_next_path_position()).normalized()

		if dir.length() > 0:
			Enemy_state = "Walking"
		else:
			Enemy_state = "Idle"

		velocity = dir * speed * delta
		play_anim(dir)
		
		move_and_slide()
	else:
		Enemy_state = "Idle"
		velocity = Vector2.ZERO

		last_shot_time += delta
		if last_shot_time >= shoot_interval:
			shoot(theta)
			last_shot_time = 0.0  #Nulstil timeren

func play_anim(_dir):
	if Enemy_state == "Idle":
		animated_sprite.play("Idle")
	elif Enemy_state == "Walking":
		animated_sprite.play("Walk")

func make_path() -> void:
	nav_agent.target_position = player.global_position

func _on_move_timer_timeout():
	make_path()

func die():
	for i in range(coinNum):
		dropCoin()
	queue_free()
	controller.checkDeath()

func dropCoin():
	var coin_instance = coin_scene.instantiate()
	coin_instance.global_position = global_position
	get_tree().get_root().call_deferred("add_child", coin_instance)

func hit_damage(damage):
	health -= damage
	$AnimatedSprite2D/AnimationPlayer.play("Hurt")
	if health <= 0:
		die()

func _on_view_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_attack_range = true

func _on_view_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_attack_range = false
