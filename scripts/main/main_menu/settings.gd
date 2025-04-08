extends Node

@onready var Logo = $Logo
@onready var Bg = $Background
var logo_up = true #bevæger loget sig op?
var i = 0
var logo_movement = 100

#func _ready():
	#var win = get_viewport().size
	#Bg.size = win
	#Logo.size = win

func _process(_delta):
	if logo_up == false:
		Logo.position -= Vector2(0, 0.1)
		i += 1
		if i > logo_movement:
			i = 0
			logo_up = true
	else:
		Logo.position += Vector2(0, 0.1)
		i += 1
		if i > logo_movement:
			i = 0
			logo_up = false



func _on_admin_pressed() -> void:
	PlayerInfo.current_coins = 999999999
	$Decoration/Hoved.texture = load("res://sprites/boss/gigaged/krop_venstre/gigaged-venstre_tramp1-hoved-venstre_angreb.png")



func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu/main_menu.tscn")


func _on_audio_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu/audiosetting.tscn")
