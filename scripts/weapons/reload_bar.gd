extends HSlider

@onready var weapon = $"../Weapon"
var reload_timer: float = 0.0

func _ready() -> void:
	visible = false
	max_value = 0

func weaponChanged():
	if weapon.weapons[weapon.currentWeapon].name == "Boomerang (weapon)": # band aid solution
		return
	
	if weapon.weapons[weapon.currentWeapon].ranged == true: 
		max_value = weapon.weapons[weapon.currentWeapon].reloadTime
		value = 0
		reload_timer = 0
		
		print("Reload time set to: ", max_value)
		set_process(true)
	else:
		set_process(false)

func _process(delta: float) -> void:
	var current_weapon = weapon.weapons[weapon.currentWeapon]
	if current_weapon.ranged == true:
		if current_weapon.reloading == true and not current_weapon.is_in_group("Boomerang"):
			print(max_value)
			if current_weapon.reserveAmmo == 0 and current_weapon.currentAmmo == 0:
				return
			if max_value <= 0:
				return
			
			visible = true
			
			reload_timer += delta
			value = reload_timer
			
			
			if value > max_value:
				value = max_value
				
		elif current_weapon.reloading == false:
			value = 0
			reload_timer = 0
			visible = false
	else:
		visible = false
