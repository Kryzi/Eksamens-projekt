extends Node2D

func _ready() -> void:
	add_to_group("item")

@onready var weapon = get_node("/root/Main/Player/Weapon")
@onready var num = 1

@export var itemValue: PackedScene
var itemID = 0

func itemGenerator():
	var Item1 = $ItemArea/Item1
	var Item2 = $ItemArea/Item2
	
	Item1.visible = false
	Item2.visible = false
	
	itemID = randi_range(1,2)
	#itemValue = preload("res://Scenes/Item.tscn")
	match itemID:
		1:
			Item1.visible = true
		2:
			Item2.visible = true
		#3:
			#itemValue = preload("res://Scenes/Items/Item3.tscn")
		#4:
			#itemValue = preload("res://Scenes/Items/Item4.tscn")


func _on_item_area_body_entered(_body: Node2D) -> void:
	
	match itemID:
		1:
			weapon.applyUpgrades( num, num)
		2:
			weapon.applyHealthUpgrade(num, num)
		#3:
			#itemValue = preload("res://Scenes/Items/Item3.tscn")
		#4:
			#itemValue = preload("res://Scenes/Items/Item4.tscn")
	
	#print("item Pickup")
	queue_free()
	
