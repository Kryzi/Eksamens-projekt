extends Node2D

@onready var weapon = get_node("/root/Main/Player/Weapon")
@onready var SpeechText = $SpeechBubbleText
@onready var animSprite = $ShopKeeperSprite
var SpeechTime = 2.5

var refillPrice = 10

func _ready() -> void:
	$RefillAmmo.text = "Refill Ammo For Current Weapon: " + str(refillPrice) + " Coins"
	$ShopKeeperSprite.play("Idle")


func _on_refill_ammo_pressed() -> void:
	var currentWeapon = weapon.weapons[weapon.currentWeapon]
	if weapon.weapons[weapon.currentWeapon].ranged == false:
		SpeechText.text = "Du har et melee våben, klovn!"
		textfelt()
	elif weapon.weapons[weapon.currentWeapon].reserveAmmo == weapon.weapons[weapon.currentWeapon].maxAmmo:
		SpeechText.text = "Du kan ikke have flere skud, din ostehaps"
		textfelt()
	elif PlayerInfo.current_coins <= refillPrice - 1 and weapon.weapons[weapon.currentWeapon].ranged == true:
		SpeechText.text = "Du fattig, taber!"
		textfelt()
		return
	elif weapon.weapons[weapon.currentWeapon].refillCount == 2:
		SpeechText.text = "Du har fyldt den op for mange gange!"
		textfelt()
		return
	
	
	if weapon.weapons[weapon.currentWeapon].ranged == true and weapon.weapons[weapon.currentWeapon].reserveAmmo != weapon.weapons[weapon.currentWeapon].maxAmmo:
		PlayerInfo.current_coins -= refillPrice
		weapon.weapons[weapon.currentWeapon].reserveAmmo = weapon.weapons[weapon.currentWeapon].maxAmmo
		weapon.weapons[weapon.currentWeapon].currentAmmo = weapon.weapons[weapon.currentWeapon].magSize
		weapon.weapons[weapon.currentWeapon].reloading = false
		
		
		weapon.weapons[weapon.currentWeapon].refillCount += 1
		
		PlayerInfo.ammo_data = {
		"current_ammo": weapon.weapons[weapon.currentWeapon].currentAmmo,
		"mag_size": weapon.weapons[weapon.currentWeapon].magSize,
		"reserve_ammo": weapon.weapons[weapon.currentWeapon].reserveAmmo
		}
		
		SpeechText.text = "Jo tak, min fine ven!"
		textfelt()
		
	
	

func textfelt():
	$SpeechBubble.visible = true
	SpeechText.visible = true
	$ShopKeeperSprite.play("Talk")
	
	await get_tree().create_timer(SpeechTime).timeout
	
	SpeechText.visible = false
	$ShopKeeperSprite.play("Idle")
	$SpeechBubble.visible = false


func _on_refill_ammo_mouse_entered() -> void:
	PlayerInfo.is_interacting_with_UI = true


func _on_refill_ammo_mouse_exited() -> void:
	PlayerInfo.is_interacting_with_UI = false
