extends Node2D

@export var Boomerang: PackedScene
@export var Firerate: float
var CanThrow: bool = true
@export var autofire: bool = false
@export var damage: int = 5

var currentAmmo: int 
@export var magSize: int = 1  # Antal boomerangs man kan have
var reserveAmmo: int 
@export var maxAmmo: int = 30
var reloading = false
## Mængden af gange våbnet har fået ammo tilbage
@export var refillCount = 0

var ranged = true

# Reference to the boomerang sprite (assuming it's a child of the player)
@onready var boomerangSprite = $AnimatedSprite2D
@onready var BoomerangSound = $BoomerangSound

func _ready() -> void:
	currentAmmo = magSize
	reserveAmmo = maxAmmo
	$AnimatedSprite2D.play("Idle")

func _process(_delta: float) -> void:
	if PlayerInfo.is_interacting_with_UI == true:
		return
		
	look_at(get_global_mouse_position())

	if Input.is_action_just_pressed("Shoot") and CanThrow and not reloading and currentAmmo > 0:
		CanThrow = false
		throw_boomerang()
		await get_tree().create_timer(Firerate).timeout
		CanThrow = true

	if currentAmmo <= 0 and (Input.is_action_pressed("Shoot") or Input.is_action_just_pressed("Reload")) and reserveAmmo > 0 and not reloading:
		reload()

func reload():
	reloading = true
	if reserveAmmo <= 0:
		print("No boomerangs left")
	else:
		var tempAmmo = currentAmmo
		if tempAmmo == 0:
			currentAmmo = magSize
			reserveAmmo -= magSize
		else:
			currentAmmo = magSize
			reserveAmmo -= (magSize - tempAmmo)

		if reserveAmmo < 0:
			currentAmmo += reserveAmmo
			reserveAmmo = 0

func throw_boomerang():
	currentAmmo -= 1
	
	BoomerangSound.play()
	PlayerInfo.ammo_data = {
		"current_ammo": currentAmmo,
		"mag_size": magSize,
		"reserve_ammo": reserveAmmo
	}
	
	# Make the boomerang sprite invisible while throwing
	boomerangSprite.visible = false
	
	var boomerang = Boomerang.instantiate()
	boomerang.global_position = $ShootingPoint.global_position
	boomerang.rotation = rotation
	boomerang.targetPos = get_global_mouse_position()
	boomerang.Damage = damage
	get_tree().get_root().call_deferred("add_child", boomerang)
	
	# The boomerang will make the sprite visible again when it's done returning

func makeVisible():
	boomerangSprite.visible = true
	reloading = false
	BoomerangSound.stop()
	
	
	PlayerInfo.ammo_data = {
		"current_ammo": currentAmmo,
		"mag_size": magSize,
		"reserve_ammo": reserveAmmo
	}
