extends Area2D

var coin_value: int = 1

func _ready() -> void:
	add_to_group("coin")

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		# Brug variabler fra PlayerInfo, så sender den automatisk et signal til HUD
		PlayerInfo.current_coins += coin_value
		queue_free()
