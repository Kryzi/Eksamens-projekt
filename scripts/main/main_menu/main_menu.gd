extends Node


#@onready var Click = $ClickButton
@export var main_scene: PackedScene
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

func _on_start_pressed() -> void:
	#Click.play()
	#if Click.playing:
	#	await Click.finished
	get_tree().change_scene_to_packed(main_scene)
	#get_tree().change_scene_to_file("res://Scenes/main.tscn")

func _on_exit_pressed() -> void:
	#Click.play()
	#if Click.playing:
	#	await Click.finished
	get_tree().quit()

func _on_settings_pressed() -> void:
	#Click.play()
	#if Click.playing:
	#	await Click.finished
	get_tree().change_scene_to_file("res://scenes/main_menu/settings.tscn")
