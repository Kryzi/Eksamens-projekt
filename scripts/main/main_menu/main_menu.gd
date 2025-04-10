extends Node


#@onready var Click = $ClickButton
@export var main_scene: PackedScene
@onready var Logo = $Logo
@onready var Bg = $Background
var logo_up = true #bevæger loget sig op?
var i = 0
var logo_movement = 100
#var leaderboard_scores: Dictionary

func _ready():
	%LeaderboardWindow.hide()
	%LeaderboardKnap.pressed.connect(ServerHandler._get_scores)
	
	%CurrentPlayerNameLabel2.text = "Current player name: " + PlayerInfo.player_name
	ServerHandler.request_data_received.connect(show_leaderboard_window)

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


func show_leaderboard_window(leaderboard_scores: Dictionary) -> void:
	%LeaderboardWindow.show()
	%Leaderboard.show()
	%MainMenuButtons.hide()
	var score_row_labels: Array[Node] = %LeaderBoardScoreRows.get_children()
	for score_row_label in score_row_labels:
			score_row_label.queue_free()
	if leaderboard_scores['size'] > 0:
		#for leaderboard_score in leaderboard_scores:
		for n in leaderboard_scores["size"]:
			var score_row_label = Label.new()
			#var player_name := str(leaderboard_score['player_name'])
			var leaderboard_score: Dictionary = leaderboard_scores[str(n)]
			var score = int(leaderboard_score['score'])
			var player_name := str(leaderboard_score['player_name'])
			var leaderboard_ranking = str(n + 1)
			score_row_label.text = leaderboard_ranking + ". " + \
				player_name + " won in " + \
				PlayerInfo.display_timer_in_min_and_s(score)
			score_row_label.set("theme_override_font_sizes/font_size", 25)
			%LeaderBoardScoreRows.add_child(score_row_label)
	else:
		var no_data_label = Label.new()
		no_data_label.text = "No highscore set yet"
		no_data_label.set("theme_override_font_sizes/font_size", 25)
		%LeaderBoardScoreRows.add_child(no_data_label)
		


func _on_to_main_menu_button_pressed() -> void:
	%LeaderboardWindow.hide()
	%MainMenuButtons.show()


func _on_confirm_name_change_button_pressed() -> void:
	PlayerInfo.player_name = %NameChangeField.text
	%CurrentPlayerNameLabel2.text = "Current player name: " + PlayerInfo.player_name
	%NameChangeConfirmationLabel.show()
	await get_tree().create_timer(2).timeout
	%NameChangeConfirmationLabel.hide()
