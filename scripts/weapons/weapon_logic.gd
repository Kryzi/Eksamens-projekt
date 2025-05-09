extends Node2D

var weapons: Array[Node] = []
var currentWeapon = 0

var canSwap = true

var totalDamageUpgrades = 0
var totalFirerateRangedUpgrades = 0
var totalFirerateMeleeUpgrages = 0

@onready var HUD = get_node("/root/Main/HUD")

func _ready() -> void:
	getWeapons()
	disableWeapons()
	enableWeapon()
	
	PlayerInfo.ammo_data = {
		"current_ammo": weapons[currentWeapon].currentAmmo,
		"mag_size": weapons[currentWeapon].magSize,
		"reserve_ammo": weapons[currentWeapon].reserveAmmo
	}

func _process(_delta: float) -> void:
	if weapons[currentWeapon].ranged == false:
		
		if weapons[currentWeapon].attacking == true:
			canSwap = false
		else:
			canSwap = true
	if Input.is_action_just_pressed("g") and weapons.size() > currentWeapon and weapons.size() > 1 :
		deleteWeapon()
		
	
	if weapons[currentWeapon].ranged == true:
		if get_global_mouse_position().x < get_parent().global_position.x:
			position.x = -40
		else:
			position.x = 40
		
		if Input.is_action_pressed("Shoot") or weapons[currentWeapon].reloading == true:
			canSwap = false
		elif Input.is_action_just_released("Shoot") and weapons[currentWeapon].reloading == false or weapons[currentWeapon].reloading == false:
			canSwap = true
		if weapons[currentWeapon].currentAmmo == 0 and weapons[currentWeapon].reserveAmmo == 0:
			canSwap = true

	for i in range(1,10):  # looper 1 to 9
		if Input.is_action_just_pressed(str(i)) and weapons.size() >= i and canSwap == true:
			weaponSwapped(i - 1)
	if Input.is_action_just_pressed("0") and weapons.size() == 10 and canSwap == true:
		weaponSwapped(9)

func deleteWeapon():
	disableWeapons()
	weapons[currentWeapon].queue_free()
	weapons.remove_at(currentWeapon)
	
	if weapons.size() == 0:
		currentWeapon = -1
		return
	elif currentWeapon >= weapons.size():
		currentWeapon = weapons.size() - 1
	weaponSwapped(currentWeapon)

func getWeapons():
	weapons = get_children()

func disableWeapons():
	for i in weapons.size():
		weapons[i].set_process(false)
		weapons[i].visible = false
		
		if weapons[i].is_in_group("Skjold"):
			weapons[i].set_active(false)

func enableWeapon():
	weapons[currentWeapon].set_process(true)
	weapons[currentWeapon].visible = true

func weaponSwapped(i):
	disableWeapons()
	
	currentWeapon = i
	enableWeapon()
	
	var inventory = get_node("/root/Main/HUD/Control/Inventory")
	inventory.checkForNewWeapons()
	inventory.HighlightWeapon()
	
	$"../ReloadBar".weaponChanged() #ændre reloadbaren til ens våben 
	
	if weapons[currentWeapon].is_in_group("Skjold"):
		weapons[currentWeapon].set_active(true)
	
	PlayerInfo.ammo_data = {
		"current_ammo": weapons[currentWeapon].currentAmmo,
		"mag_size": weapons[currentWeapon].magSize,
		"reserve_ammo": weapons[currentWeapon].reserveAmmo
	}

func applyUpgrades(damageUpgrade: int, _FirerateUpgrade: float):
	applyDamageUp(damageUpgrade)

func applyDamageUp(_damageUpgrade: int):
	for i in weapons.size():
		if weapons[i].is_in_group("Skjold"):
			pass
		else:
			var original_damage = weapons[i].damage
			var bonus = original_damage * 0.20
			if bonus < 1:
				bonus = 1
			weapons[i].damage += bonus
			totalDamageUpgrades += bonus
			'weapons[i].damage += damageUpgrade
			totalDamageUpgrades += damageUpgrade'

func applyFirerateRangedUp(FirerateRangedUpgrade: float):
	for i in weapons.size():
		if weapons[i].ranged == true:
			weapons[i].Firerate /= FirerateRangedUpgrade
			totalFirerateRangedUpgrades += FirerateRangedUpgrade

func applyFirerateMeleeUp(FirerateMeleeUpgrade: float):
	for i in weapons.size():
		if weapons[i].ranged == false:
			if weapons[i].is_in_group("Skjold"):
				pass
			else:
				weapons[i].FPS_SpeedScale *= FirerateMeleeUpgrade
				weapons[i]._ready()
				totalFirerateMeleeUpgrages += FirerateMeleeUpgrade

func applyHealthUpgrade(extra_health: int, heal: bool = true):
	PlayerInfo.health_data = {
		"max_health": PlayerInfo.health_data["max_health"] + extra_health,
		"current_health": PlayerInfo.health_data["max_health"] + extra_health if heal == true else PlayerInfo.health_data["current_health"] + extra_health
	}
	extra_health = extra_health * 1.2

func applyUpgradeNewWeapon(i: int):
	if weapons[i].is_in_group("Skjold"):
		return
	weapons[i].damage += totalDamageUpgrades
	if weapons[i].ranged == true and totalFirerateRangedUpgrades > 0:
		weapons[i].Firerate /= totalFirerateRangedUpgrades 
		
	elif weapons[i].ranged == false and totalFirerateMeleeUpgrages > 0:
		weapons[i].FPS_SpeedScale *= totalFirerateMeleeUpgrages
		weapons[i]._ready()
	'print("is used")'
