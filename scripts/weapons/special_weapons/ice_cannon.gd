extends Node2D

@export var Bullet: PackedScene
@export var Firerate: float
var CanShoot: bool = true
@export var autofire: bool = false
@export var damage: int = 5

var currentAmmo: int # Mængden af skud man har lige nu i våbenet
@export var magSize: int = 12
var reserveAmmo: int # Den mængde skud man har, i alt
@export var maxAmmo: int = 12
@export var reloadTime: float 
var reloading = false
@export var refillCount = 0

@export var recoil_force = 1200.0  # Højere værdi for en mærkbar effekt

@onready var CanonSound = $CanonSound

var ranged = true

func _ready() -> void:
	currentAmmo = magSize
	reserveAmmo = maxAmmo
	
	$AnimatedSprite2D.play("Idle")

func _process(_delta: float) -> void:
	if PlayerInfo.is_interacting_with_UI == true:
		return
	
	look_at(get_global_mouse_position())
	
	if Input.is_action_just_pressed("Shoot") and CanShoot == true and autofire == false and reloading == false and currentAmmo > 0:
		CanShoot = false
		
		shoot()
		
		await get_tree().create_timer(Firerate).timeout
		CanShoot = true
	
	if autofire == true:
		while Input.is_action_pressed("Shoot") and CanShoot == true and reloading == false:
			CanShoot = false
			
			shoot()
			
			await get_tree().create_timer(Firerate).timeout
			CanShoot = true
	
	await get_tree().create_timer(0.0001).timeout
	if currentAmmo <= 0 and Input.is_action_just_pressed("Shoot") or Input.is_action_just_pressed("Reload") and reserveAmmo > 0 and reloading == false and currentAmmo != magSize:
		reload()

func reload():
	reloading = true
	if reserveAmmo <= 0:
		'print("no bullets left")'
		
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
		
		await get_tree().create_timer(reloadTime).timeout
		
		PlayerInfo.ammo_data = {
		"current_ammo": currentAmmo,
		"mag_size": magSize,
		"reserve_ammo": reserveAmmo
	}
		reloading = false

func shoot():
	currentAmmo -= 1
	
	$AnimatedSprite2D.play("Attack")
	CanonSound.play()
	PlayerInfo.ammo_data = {
		"current_ammo": currentAmmo,
		"mag_size": magSize,
		"reserve_ammo": reserveAmmo
	}
	get_node("/root/Main/HUD").NOISE_SHAKE_STRENGTH = 50.0
	get_node("/root/Main/HUD").apply_noise_shake()
	get_node("/root/Main/HUD").NOISE_SHAKE_STRENGTH = 15.0
	
	var bullet = Bullet.instantiate()
	bullet.global_position = $ShootingPoint.global_position
	bullet.rotation = rotation
	bullet.targetPos = get_global_mouse_position() 
	bullet.Damage = damage
	get_tree().get_root().call_deferred("add_child", bullet)
	
	var player = get_node("/root/Main/Player")
	
	var recoil_direction = (player.global_position - get_global_mouse_position()).normalized()
	player.recoil_velocity += recoil_direction * recoil_force
