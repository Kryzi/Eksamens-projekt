extends Node2D

## Mængden af damage våbenet gør per slag
@export var damage: int
## Her svarer 1 til den normale animation og 2 til en dobbelt så hurtigt animation
@export var FPS_SpeedScale: float = 1 
## Distancen våbenet har til splleren
@export var rotation_radius: float = 50.0

@onready var HammerSound = $HammerSound

var currentAmmo = 999
var magSize = 999
var reserveAmmo = 999
var attacking = false
var ranged = false

func _ready() -> void:
	$AnimatedSprite2D.play("Idle")
	$AnimatedSprite2D.speed_scale = FPS_SpeedScale

func _process(_delta: float) -> void:
	if PlayerInfo.is_interacting_with_UI == true:
		return

	var player = get_node("/root/Main/Player")  
	
	var direction = (get_global_mouse_position() - player.global_position).normalized()
	global_position = player.global_position + direction * rotation_radius
	look_at(get_global_mouse_position())
	
	
	
	if Input.is_action_just_pressed("Shoot") and attacking == false:
		attacking = true
		$AnimatedSprite2D.play("Windup")
		await $AnimatedSprite2D.animation_finished
		
		$AnimatedSprite2D.play("Attack")
		HammerSound.play()
		$Hurtbox.monitoring = true
		
		
		get_node("/root/Main/HUD").NOISE_SHAKE_STRENGTH = 100.0
		get_node("/root/Main/HUD").apply_noise_shake()
		get_node("/root/Main/HUD").NOISE_SHAKE_STRENGTH = 15.0
		
		await $AnimatedSprite2D.animation_finished
		
		$Hurtbox.monitoring = false
		attacking = false
		$AnimatedSprite2D.play("Idle")


func _on_hurtbox_body_entered(body: Node2D) -> void:
	if (body.is_in_group("enemy")):
		body.hit_damage(damage)
