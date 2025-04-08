extends Node


func _on_admin_pressed() -> void:
	pass # Replace with function body.


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu/main_menu.tscn")


func _on_audio_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu/audiosetting.tscn")
