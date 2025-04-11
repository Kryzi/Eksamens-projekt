extends PanelContainer
var weapon_resource: ShopItemResource
@onready var PlayerWeapons = get_node("/root/Main/Player/Weapon")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%ShopItemTextureRect.texture = weapon_resource.shop_texture
	%PurchaseButton.set_text(weapon_resource.weapon_name + ": " + str(weapon_resource.cost) + " coins")



func _on_purchase_button_pressed() -> void:
	if (PlayerInfo.current_coins >= weapon_resource.cost and PlayerWeapons.get_child_count() < PlayerInfo.weaponLimit):
		PlayerInfo.current_coins -= weapon_resource.cost
		%PurchaseButton.disabled = true
		var weapon_instance = weapon_resource.scene.instantiate()
		weapon_instance.hide()
		PlayerWeapons.add_child(weapon_instance)
		PlayerWeapons.getWeapons()
		var new_weapon_index = PlayerWeapons.weapons.find(weapon_instance)
		PlayerWeapons.disableWeapons()
		PlayerWeapons.enableWeapon()
		
		# Giver tidligere upgraderinger til nye våben
		PlayerWeapons.applyUpgradeNewWeapon(new_weapon_index)
		
		var inventory = get_node("/root/Main/HUD/Control/Inventory")
		inventory.checkForNewWeapons()
		inventory.HighlightWeapon()

func _on_purchase_button_mouse_entered() -> void:
	PlayerInfo.is_interacting_with_UI = true


func _on_purchase_button_mouse_exited() -> void:
	PlayerInfo.is_interacting_with_UI = false
