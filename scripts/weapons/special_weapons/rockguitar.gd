extends Node2D

## Indsæt skudet dit våben skal skyde med her!
@export var Bullet: PackedScene
## Tiden det tager til at man kan skyde igen
@export var Firerate: float
var CanShoot: bool = true
## Dette ændre hvis man kan holdd skydeknappen nede for at blive ved med at skyde
@export var autofire: bool = false
## Mængden af damage hvert skud gør
@export var damage: int = 5
@export var WeaponSound: AudioStreamPlayer

var currentAmmo: int # Mængden af skud man har lige nu i våbenet
## Mængden af skud man kan have per reload
@export var magSize: int = 12
var reserveAmmo: int # Den mængde skud man har, i alt
## Højste mængde af skud man kan have
@export var maxAmmo: int = 12
## Tiden det tager at reload
@export var reloadTime: float 
var reloading = false

@export var num_bullets: int = 4
@export var shot_delay: float = 0.1
var ranged = true



func _ready() -> void:
	currentAmmo = magSize
	reserveAmmo = maxAmmo
	
	
	
	$AnimatedSprite2D.play("Idle")

func _process(_delta: float) -> void:
	if PlayerInfo.is_interacting_with_UI == true:
		return
	
	look_at(get_global_mouse_position())
	
	if Input.is_action_just_pressed("Shoot") and CanShoot == true and autofire == false and reloading == false:
		CanShoot = false
		
		shoot()
		
		
		await get_tree().create_timer(Firerate).timeout
		CanShoot = true
	
	if autofire == true:
		while Input.is_action_pressed("Shoot") and CanShoot == true and reloading == false:
			CanShoot = false
			
			reloading = true
			shoot()
			
	
	if currentAmmo <= 0 and Input.is_action_pressed("Shoot") or Input.is_action_just_pressed("Reload") and reserveAmmo > 0 and reloading == false:
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
		
		# Brug variabler fra PlayerInfo, så sender den automatisk et signal til HUD
		PlayerInfo.ammo_data = {
		"current_ammo": currentAmmo,
		"mag_size": magSize,
		"reserve_ammo": reserveAmmo
	}
		
		reloading = false

func shoot():
	for i in range(num_bullets):
		currentAmmo -= 1
		
		WeaponSound.play()
		$AnimatedSprite2D.play("Attack")
		PlayerInfo.ammo_data = {
			"current_ammo": currentAmmo,
			"mag_size": magSize,
			"reserve_ammo": reserveAmmo
		}
		
		var offset = Vector2(randf_range(-100, 100), randf_range(-100, 100))
		
		var bullet = Bullet.instantiate()
		bullet.global_position = $ShootingPoint.global_position
		bullet.rotation = rotation
		bullet.targetPos = get_global_mouse_position()  + offset
		bullet.Damage = damage
		get_tree().get_root().call_deferred("add_child", bullet)
		
		
		
		await get_tree().create_timer(shot_delay).timeout  # Vent lidt mellem skud
	
	await get_tree().create_timer(Firerate).timeout
	CanShoot = true
	reloading = false
