extends CanvasLayer

@export var NOISE_SHAKE_SPEED: float = 15.0
@export var NOISE_SWAY_SPEED: float = 1.0
@export var NOISE_SHAKE_STRENGTH: float = 15.0
@export var NOISE_SWAY_STRENGTH: float = 10.0
@export var RANDOM_SHAKE_STRENGTH: float = 30.0
@export var SHAKE_DECAY_RATE: float = 3.0

enum ShakeType {
	Random,
	Noise,
	Sway
}

@onready var camera = get_node("/root/Main/Player/Camera2D")
@onready var weapon: Node2D = get_node("/root/Main/Player/Weapon")

@onready var noise = FastNoiseLite.new()
var noise_i: float = 0.0
@onready var rand = RandomNumberGenerator.new()
var shake_type: int = ShakeType.Random
var shake_strength: float = 0.0





func _ready() -> void:
	%EndScreenPanel.hide()
	PlayerInfo.coin_count_changed.connect(updateCoins)
	PlayerInfo.health_changed.connect(updateHealthBar)
	PlayerInfo.ammo_changed.connect(updateAmmo)
	PlayerInfo.win_screen_reached.connect(showEndScreen)
	
	updateCoins(PlayerInfo.current_coins)
	updateHealthBar(PlayerInfo.health_data)
	updateAmmo(PlayerInfo.ammo_data)
	
	rand.randomize()
	noise.seed = rand.randi()
	noise.frequency = 0.5


func updateAmmo(new_ammo_data: Dictionary):
	var newCurrentAmmo = new_ammo_data["current_ammo"]
	var newMagSize = new_ammo_data["mag_size"]
	var newReserveAmmo = new_ammo_data["reserve_ammo"]
	
	%AmmoLabel.set_text(
		"Ammo: " + str(newCurrentAmmo) + " / " + str(newMagSize) +
		" (Reserve: " + str(newReserveAmmo) + ")"
	)

func updateCoins(newCoins: int) -> void:
	%CoinsLabel.set_text("Coins: " + str(newCoins))
	
func showEndScreen(is_player_a_winner: bool, timer_string: int):
	if is_player_a_winner:
		%EndScreenTextLabel.set_text("You win")
		%HighScoreLabel.set_text("You defeated the Gigagoat in " + \
			PlayerInfo.display_timer_in_min_and_s(timer_string))
	else:
		%EndScreenTextLabel.set_text("Game over")
		%HighScoreLabel.set_text("You didn't defeat the Gigagoat")
	
	%EndScreenPanel.show()
	get_tree().paused = true
	
func updateHealthBar(new_health_data: Dictionary):
	var new_max_health = new_health_data["max_health"]
	var new_current_health = new_health_data["current_health"]
	%HealthBar.max_value = new_max_health
	%HealthBar.value = new_current_health

func _on_main_menu_pressed() -> void:
	PlayerInfo.bossTimer = 0
	PlayerInfo.Timer = 0
	PlayerInfo.current_coins = 0
	PlayerInfo.weaponLimitCost = 10
	PlayerInfo.weaponLimit = 5
	PlayerInfo.health_data = {
	"current_health": 12,
	"max_health": 12 }
	weapon.totalDamageUpgrades = 0
	weapon.totalFirerateRangedUpgrades = 0
	weapon.totalFirerateMeleeUpgrages = 0
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main_menu/main_menu.tscn")
	
func _on_button_pressed() -> void:
	get_tree().quit()


func _on_retry_button_pressed() -> void:
	PlayerInfo.bossTimer = 0
	PlayerInfo.Timer = 0
	PlayerInfo.current_coins = 0
	PlayerInfo.weaponLimitCost = 10
	PlayerInfo.weaponLimit = 5
	PlayerInfo.health_data = {
	"current_health": 12,
	"max_health": 12 }
	weapon.totalDamageUpgrades = 0
	weapon.totalFirerateRangedUpgrades = 0
	weapon.totalFirerateMeleeUpgrages = 0
	get_tree().paused = false
	get_tree().reload_current_scene()
	
func apply_random_shake() -> void:
	shake_strength = RANDOM_SHAKE_STRENGTH
	shake_type = ShakeType.Random
	
func apply_noise_shake() -> void:
	shake_strength = NOISE_SHAKE_STRENGTH
	shake_type = ShakeType.Noise
	
func apply_noise_sway() -> void:
	shake_type = ShakeType.Sway
	
func _process(delta: float) -> void:
	shake_strength = lerp(shake_strength, 0.0, SHAKE_DECAY_RATE * delta)
	
	var shake_offset: Vector2
	
	match shake_type:
		ShakeType.Random:
			shake_offset = get_random_offset()
		ShakeType.Noise:
			shake_offset = get_noise_offset(delta, NOISE_SHAKE_SPEED, shake_strength)
		ShakeType.Sway:
			shake_offset = get_noise_offset(delta, NOISE_SWAY_SPEED, NOISE_SWAY_STRENGTH)
	camera.offset = shake_offset

func get_noise_offset(delta: float, speed: float, strength: float) -> Vector2:
	noise_i += delta * speed
	return Vector2(
		noise.get_noise_2d(1, noise_i) * strength,
		noise.get_noise_2d(100, noise_i) * strength
	)

func get_random_offset() -> Vector2:
	return Vector2(
		rand.randf_range(-shake_strength, shake_strength),
		rand.randf_range(-shake_strength, shake_strength)
	)
