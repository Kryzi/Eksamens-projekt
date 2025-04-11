extends Area2D

@export var speed: int = 600
@export var return_speed: int = 800
@export var max_distance: float = 400
var Damage: int = 5
var targetPos: Vector2
var direction: Vector2
var start_position: Vector2
var returning: bool = false
var player: CharacterBody2D  

func _ready() -> void:
	$AnimatedSprite2D.play("Idle")
	start_position = global_position
	player = get_node("/root/Main/Player")
	direction = (targetPos - global_position).normalized()

func _physics_process(delta):
	if returning:
		direction = (player.global_position - global_position).normalized()
		position += direction * return_speed * delta
	if global_position.distance_to(player.global_position) < 20:
		destroy()
		get_node("/root/Main/Player/Weapon").weapons[get_node("/root/Main/Player/Weapon").currentWeapon].makeVisible()
	else:
		position += direction * speed * delta
	if global_position.distance_to(start_position) >= max_distance:
		returning = true

func destroy():
	queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		body.hit_damage(Damage)
		returning = true
	elif not body.is_in_group("player"):
		returning = true
