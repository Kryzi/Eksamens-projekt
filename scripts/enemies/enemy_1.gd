extends CharacterBody2D

var speed = 10000
var health = 18
var Enemy_state: String = "Walking"
var last_direction: Vector2 = Vector2.DOWN
var player_in_attack_range = false

@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var player = get_node("/root/Main/Player")
@onready var controller = get_node("/root/Main/MapController/Spawner")
@onready var animated_sprite = $AnimatedSprite2D
@onready var attack_area = $View
@onready var ShootSound = $Enemy1Sound

@export var bullet_scene: PackedScene
@export var coin_scene: PackedScene
@export var coinNum: int

func _physics_process(delta) -> void:
	if not player_in_attack_range:
		var dir = to_local(nav_agent.get_next_path_position()).normalized()

		if dir.length() > 0:
			Enemy_state = "Walking"
			last_direction = dir
		else:
			Enemy_state = "Idle"

		velocity = dir * speed * delta
		play_anim(dir)
		
		move_and_slide()
	else:
		Enemy_state = "Idle"
		velocity = Vector2.ZERO

func play_anim(dir):
	if Enemy_state == "Idle":
		animated_sprite.play("Idle " + Aimdirection(last_direction))
	elif Enemy_state == "Walking":
		animated_sprite.play("Walk " + Aimdirection(dir))

func Aimdirection(dir: Vector2) -> String:
	if abs(dir.x) > abs(dir.y):
		return "højre" if dir.x > 0 else "venstre"
	else:
		return "ned" if dir.y > 0 else "op"

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

func shoot():
	if player_in_attack_range:
		ShootSound.play()
		animated_sprite.play("Angreb " + Aimdirection(last_direction))
		var bullet_instance = bullet_scene.instantiate()
		bullet_instance.global_position = $ShootingPoint.global_position
		bullet_instance.rotation = rotation
		bullet_instance.targetPos = player.global_position  
		get_tree().get_root().call_deferred("add_child", bullet_instance)  

func _on_attack_timer_timeout() -> void:
	if player_in_attack_range:
		shoot()
		await animated_sprite.animation_finished

func _on_view_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_attack_range = true

func _on_view_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_attack_range = false
