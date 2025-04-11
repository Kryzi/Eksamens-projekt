extends VBoxContainer

const MUSIC_BUS = "Music"
const SFX_BUS = "Sfx"
const MASTER_BUS = "Master"

@onready var SfxSound = $SwitchOn

func _on_master_slider_value_changed(value):
	var BusInt = AudioServer.get_bus_index(MUSIC_BUS)
	AudioServer.set_bus_volume_db(BusInt, value)


func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/main_menu/main_menu.tscn")


func _on_music_slider_value_changed(value):
	var BusInt = AudioServer.get_bus_index(MUSIC_BUS)
	AudioServer.set_bus_volume_db(BusInt, value)


func _on_sfx_slider_value_changed(value):
	var BusInt = AudioServer.get_bus_index(SFX_BUS)
	AudioServer.set_bus_volume_db(BusInt, value)


func _on_sfx_button_pressed():
	SfxSound.play()
