extends Control

@export var basic_bow_scene: PackedScene
@export var basic_bow_texture: Texture2D
@export var basic_bow_cost: int
var basic_bow_name: String = "Basic bow"

@export var basic_knife_scene: PackedScene
@export var basic_knife_texture: Texture2D
@export var basic_knife_cost: int
var basic_knife_name: String = "Basic knife"

@export var boomerang_scene: PackedScene
@export var boomerang_texture: Texture2D
@export var boomerang_cost: int
var boomerang_name: String = "Boomerang"

@export var water_staff_scene: PackedScene
@export var water_staff_texture: Texture2D
@export var water_staff_cost: int
var water_staff_name: String = "Water staff"

@export var giant_hammer_scene: PackedScene
@export var giant_hammer_texture: Texture2D
@export var giant_hammer_cost: int
var giant_hammer_name: String = "Giant hammer"

@export var shield_scene: PackedScene
@export var shield_texture: Texture2D
@export var shield_cost: int
var shield_name: String = "Shield"

@export var shop_item_slot_scene: PackedScene
@export var number_of_shop_item_slots: int = 5
@export var shop_item_resource_array: Array[ShopItemResource]


func _ready() -> void:
	RefillShopItems()
	%limitPurchase.set_text("Increase max weapons : " + str(PlayerInfo.weaponLimitCost) + " coins")

@onready var Inventory = get_node("/root/Main/HUD/Control/MarginContainer/Inventory")

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
		
		# Henter fra "Inventory" og gør det valgte slot synligt
		var slot_name = "Slot" + str(PlayerInfo.weaponLimit)
		var slot_node = Inventory.get_node_or_null(slot_name)
		slot_node.visible = true

	
func _on_limit_purchase_mouse_entered() -> void:
	PlayerInfo.is_interacting_with_UI = true

func _on_limit_purchase_mouse_exited() -> void:
	PlayerInfo.is_interacting_with_UI = false

@onready var spawner = get_node("/root/Main/MapController/Spawner")
var itemCost = 25
@export var item: PackedScene
func _on_item_purchase_pressed() -> void:
	if (PlayerInfo.current_coins >= itemCost):
		PlayerInfo.current_coins -= itemCost
		spawner.getItem()


	
func _on_item_purchase_mouse_entered() -> void:
	PlayerInfo.is_interacting_with_UI = true

func _on_item_purchase_mouse_exited() -> void:
	PlayerInfo.is_interacting_with_UI = false
