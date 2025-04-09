extends Node2D

@export var Bullet: PackedScene
@export var Firerate: float
@export var autofire: bool = false
@export var damage: int = 5

var currentAmmo: int
@export var magSize: int = 12
var reserveAmmo: int
@export var maxAmmo: int = 12
@export var reloadTime: float 
var reloading = false
var active_bullet: Node2D = null  # Holder styr på om et skud er aktivt
var ranged = true

@onready var ExplosionSound = $ExplosionSound



func _ready() -> void:
	currentAmmo = magSize
	reserveAmmo = maxAmmo
	$AnimatedSprite2D.play("Idle")

func _process(_delta: float) -> void:
	if PlayerInfo.is_interacting_with_UI:
		return
	
	look_at(get_global_mouse_position())
	
	if Input.is_action_just_pressed("Shoot") and active_bullet == null and reloading == false and currentAmmo > 0:
		shoot()
	
	await get_tree().create_timer(0.0001).timeout
	if active_bullet == null:
		if currentAmmo <= 0 and Input.is_action_just_pressed("Shoot") or Input.is_action_just_pressed("Reload") and reserveAmmo > 0 and currentAmmo != magSize:
			reload()

func shoot():
	if currentAmmo > 0 and active_bullet == null:
		currentAmmo -= 1
		$AnimatedSprite2D.play("Attack")
		PlayerInfo.ammo_data = {
			"current_ammo": currentAmmo,
			"mag_size": magSize,
			"reserve_ammo": reserveAmmo
		}
		
		active_bullet = Bullet.instantiate()
		active_bullet.global_position = $ShootingPoint.global_position
		active_bullet.rotation = rotation
		active_bullet.targetPos = get_global_mouse_position()
		active_bullet.Damage = damage
		
		# For at sikre, at vi fjerner referencen, når skuddet fjernes
		active_bullet.tree_exited.connect(_on_bullet_removed)
		
		get_tree().get_root().call_deferred("add_child", active_bullet)

func _on_bullet_removed():
	active_bullet = null
	$AnimatedSprite2D.play("Idle")
	reloading = false

func reload():
	reloading = true
	if reserveAmmo <= 0:
		print("No bullets left")
	else:
		var tempAmmo = currentAmmo
		currentAmmo = min(magSize, reserveAmmo + tempAmmo)
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

func Sound():
	ExplosionSound.play()
