extends Node2D

@export var Bullet: PackedScene
@export var Firerate: float
var CanShoot: bool = true
@export var autofire: bool = false
@export var damage: int = 5
@export var WeaponSound: AudioStreamPlayer

var currentAmmo: int
@export var magSize: int = 12
var reserveAmmo: int
@export var maxAmmo: int = 12
@export var reloadTime: float 
var reloading = false
@export var refillCount = 0

@export var num_bullets: int = 4
@export var shot_delay: float = 0.1
var ranged = true

var canReload

func _ready() -> void:
	currentAmmo = magSize
	reserveAmmo = maxAmmo
	$AnimatedSprite2D.play("Idle")

func _process(_delta: float) -> void:
	if PlayerInfo.is_interacting_with_UI == true:
		return
	look_at(get_global_mouse_position())
	
	if autofire == true:
		while Input.is_action_pressed("Shoot") and CanShoot == true and reloading == false and currentAmmo > 0:
			CanShoot = false
			get_parent().canSwap = false
			WeaponSound.play()
			canReload = false
			shoot()
	
	await get_tree().create_timer(0.0001).timeout
	if currentAmmo <= 0 and Input.is_action_just_pressed("Shoot") or Input.is_action_just_pressed("Reload") and reserveAmmo > 0 and reloading == false and canReload == true and currentAmmo != magSize:
		reload()

func reload():
	reloading = true
	
	if reserveAmmo <= 0:
		print("no bullets left")
		
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
	for i in range(num_bullets):
		
		currentAmmo -= 1
		
		$AnimatedSprite2D.play("Attack")
		PlayerInfo.ammo_data = {
			"current_ammo": currentAmmo,
			"mag_size": magSize,
			"reserve_ammo": reserveAmmo
		}
		
		var mouse_pos = get_global_mouse_position()
		var player_pos = global_position
		var distance = player_pos.distance_to(mouse_pos)
		
		var max_offset = 75.0
		var min_offset = 10.0
		var max_distance = 350.0
		
		var offset_strength = clamp((distance / max_distance), 0.0, 1.0)
		var offset_range = lerp(min_offset, max_offset, offset_strength)
		
		var offset = Vector2(randf_range(-offset_range, offset_range), randf_range(-offset_range, offset_range))
		
		var bullet = Bullet.instantiate()
		if i == 0:
			bullet.get_child(0).texture = load("res://sprites/vaaben/ranged/rockguitar/node-2_rockguitar.png")
		elif i == 1:
			bullet.get_child(0).texture = load("res://sprites/vaaben/ranged/rockguitar/node-1_rockguitar.png")
		elif i == 2:
			bullet.get_child(0).texture = load("res://sprites/vaaben/ranged/rockguitar/node-3_rockguitar.png")
		elif i == 3:
			bullet.get_child(0).texture = load("res://sprites/vaaben/ranged/rockguitar/node-1_rockguitar.png")
		
		bullet.global_position = $ShootingPoint.global_position
		bullet.rotation = rotation
		bullet.targetPos = mouse_pos  + offset
		bullet.Damage = damage
		get_tree().get_root().call_deferred("add_child", bullet)
		
		await get_tree().create_timer(shot_delay).timeout
	
	await get_tree().create_timer(Firerate).timeout
	CanShoot = true
	get_parent().canSwap = true
	canReload = true
	$AnimatedSprite2D.play("Idle")
