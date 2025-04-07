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
		
		$RichTextLabel.text = "Jo tak, min fine ven!"
		textfelt()
		
	else:
		if weapon.weapons[weapon.currentWeapon].ranged == false:
			$RichTextLabel.text = "Du har et melee våben, klovn!"
			textfelt()
			
		elif weapon.weapons[weapon.currentWeapon].reserveAmmo == weapon.weapons[weapon.currentWeapon].maxAmmo:
			$RichTextLabel.text = "Du kan ikke have flere skud, din ostehaps"
			textfelt()
		
	

func textfelt():
	$RichTextLabel.visible = true
	await get_tree().create_timer(2.5).timeout
	$RichTextLabel.visible = false


func _on_refill_ammo_mouse_entered() -> void:
	PlayerInfo.is_interacting_with_UI = true


func _on_refill_ammo_mouse_exited() -> void:
	PlayerInfo.is_interacting_with_UI = false


func _on_sælg_våben_pressed() -> void:
	pass
	#print(weapon.weapons[weapon.currentWeapon].instance.name)
	
	
	
