extends Node2D

func _ready() -> void:
	add_to_group("item")

@onready var weapon = get_node("/root/Main/Player/Weapon")
@onready var player = get_node("/root/Main/Player")
@onready var num = 1
@onready var ItemSound = $ItemSound

@export var itemValue: PackedScene
var itemID = 0

func itemGenerator():
	var Item1 = $ItemArea/Item1
	var Item2 = $ItemArea/Item2
	var Item3 = $ItemArea/Item3
	
	Item1.visible = false
	Item2.visible = false
	Item3.visible = false
	
	itemID = randi_range(1,4)
	#itemValue = preload("res://Scenes/Item.tscn")
	match itemID:
		1:
			Item1.visible = true
		2:
			Item2.visible = true
		3:
			Item3.visible = true
		4:
			Item1.visible = true

var picked_up = false
func _on_item_area_body_entered(_body: Node2D) -> void:
	if (picked_up == true):
		return
	if _body.is_in_group("player"):
		picked_up = true
		match itemID:
			1:
				weapon.applyUpgrades( num, num)
				ItemSound.play()
				await ItemSound.finished
			2:
				weapon.applyHealthUpgrade(num, num)
				ItemSound.play()
				await ItemSound.finished
			3:
				player.speedUpgrade()
				ItemSound.play()
				await ItemSound.finished
			4:
				weapon.applyUpgrades( num, num)
				ItemSound.play()
				await ItemSound.finished
		
		queue_free()
	
	#print("item Pickup")

	
