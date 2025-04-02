extends Node2D

## Health af skjoldet
@export var currentAmmo = 15
@export var rotation_radius: float = 50.0
@onready var Weapon = get_node("/root/Main/Player/Weapon")

@onready var player = get_node("/root/Main/Player") 
@onready var collision = $CollisionShape2D  # Hent collision shape

@onready var magSize = currentAmmo
@onready var reserveAmmo = currentAmmo
var ranged = false
var attacking = false

func _ready() -> void:
	$AnimatedSprite2D.play("Idle")

func _process(_delta: float) -> void:
	if PlayerInfo.is_interacting_with_UI == true:
		return
	
	var direction = (get_global_mouse_position() - player.global_position).normalized()
	global_position = player.global_position + direction * rotation_radius
	look_at(get_global_mouse_position())
	

func set_active(active: bool):
	if collision:
		collision.disabled = not active  # Deaktiver collision, hvis skjoldet ikke er i brug


func hit_damage(damage):
	currentAmmo -= damage
	
	PlayerInfo.ammo_data = {
		"current_ammo": currentAmmo,
		"mag_size": magSize,
		"reserve_ammo": reserveAmmo
	}
	
	if currentAmmo <= 0:
		die()

func die():
	
	$AnimatedSprite2D.play("Break")
	await $AnimatedSprite2D.animation_finished
	
	Weapon.weaponSwapped(0)
	
	for weapon in Weapon.weapons:
		if weapon.is_in_group("Skjold"):  
			Weapon.weapons.erase(weapon)  
			weapon.queue_free() 
			return  
	
	
	
