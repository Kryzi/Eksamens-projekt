extends Node2D

@onready var weapon = get_node("/root/Main/Player/Weapon")

var refillPrice = 10

func _ready() -> void:
	$RefillAmmo.text = "Refill Ammo: " + str(refillPrice) + " Coins"


func _on_refill_ammo_pressed() -> void:
	if PlayerInfo.current_coins >= refillPrice and weapon.weapons[weapon.currentWeapon].ranged == true and weapon.weapons[weapon.currentWeapon].reserveAmmo != weapon.weapons[weapon.currentWeapon].maxAmmo:
		PlayerInfo.current_coins -= refillPrice
		weapon.weapons[weapon.currentWeapon].reserveAmmo = weapon.weapons[weapon.currentWeapon].maxAmmo
		
		PlayerInfo.ammo_data = {
		"current_ammo": weapon.weapons[weapon.currentWeapon].currentAmmo,
		"mag_size": weapon.weapons[weapon.currentWeapon].magSize,
		"reserve_ammo": weapon.weapons[weapon.currentWeapon].reserveAmmo
		}
		
	else:
		print("Du har max skud eller et melee våben")
	

func _on_refill_ammo_mouse_entered() -> void:
	PlayerInfo.is_interacting_with_UI = true


func _on_refill_ammo_mouse_exited() -> void:
	PlayerInfo.is_interacting_with_UI = false
