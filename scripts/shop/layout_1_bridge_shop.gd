extends Control

@export var shop_item_slot_scene: PackedScene
@export var number_of_shop_item_slots: int = 5
@export var shop_item_resource_array: Array[ShopItemResource]


func _ready() -> void:
	RefillShopItems()
	%limitPurchase.set_text("Increase max weapons : " + str(PlayerInfo.weaponLimitCost) + " coins")


func _on_button_pressed() -> void:
	var highScore = PlayerInfo.current_coins
	PlayerInfo.player_died.emit(highScore)
	
func RefillShopItems() -> void:
	for child_node in %ShopItemsContainer.get_children():
		child_node.queue_free()

	for i in range(number_of_shop_item_slots):
		var shop_item_slot_instance = shop_item_slot_scene.instantiate()
		var shop_item_resource_instance = shop_item_resource_array.pick_random()
		shop_item_slot_instance.weapon_resource = shop_item_resource_instance
		%ShopItemsContainer.call_deferred("add_child", shop_item_slot_instance)

func _on_limit_purchase_pressed() -> void:
	if (PlayerInfo.current_coins >= PlayerInfo.weaponLimitCost and PlayerInfo.weaponLimit < 10):
		PlayerInfo.current_coins -= PlayerInfo.weaponLimitCost
		PlayerInfo.weaponLimit += 1
		PlayerInfo.weaponLimitCost += 5
		%limitPurchase.set_text("Increase max weapons : " + str(PlayerInfo.weaponLimitCost) + " coins")


func _on_limit_purchase_mouse_entered() -> void:
	PlayerInfo.is_interacting_with_UI = true

func _on_limit_purchase_mouse_exited() -> void:
	PlayerInfo.is_interacting_with_UI = false
