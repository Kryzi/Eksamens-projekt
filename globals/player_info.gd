extends Node

signal health_changed(new_health_data: Dictionary)
signal ammo_changed(new_ammo_data: Dictionary)
signal coin_count_changed(new_coins: int)
#signal game_ended(is_player_victorious: bool)
signal win_screen_reached(is_player_victorious: bool, high_score_timer: int)

# Bruges til at bestemme hvem har klaret spillet hurtigst
var timer: float = 0
var current_coins: int = 0:
	set(value):
		current_coins = value
		coin_count_changed.emit(current_coins)
		
var health_data: Dictionary = {
	"current_health": 10,
	"max_health": 10
}:
	set(value):
		health_data.merge(value, true)
		health_changed.emit(health_data)

var ammo_data: Dictionary = {
	"mag_size": 0,
	"reserve_ammo": 0,
	"current_ammo": 0
}:
	set(value):
		ammo_data.merge(value, true)
		ammo_changed.emit(ammo_data)  # Automatically emit signal when changed
		
var is_interacting_with_UI: bool = false

#Tilfældigt default navn til leaderboard, f.eks. player103
var player_name: String = "player" + str(randi_range(100,999))
# Max våben og våben kost
var weaponLimit = 3
var weaponLimitCost = 10

# Til mapcontroller og spawner
var areaID = 0
var bossTimer = 0
var mapValue: String = ""

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
func _process(delta: float) -> void:
	timer += delta

func display_timer_in_min_and_s(timer_in_seconds) -> String:
	var minutes = str(floor(timer_in_seconds / 60))
	var seconds = str(round(fmod(timer_in_seconds, 60)))
	return minutes + " min, " + seconds + " s"
