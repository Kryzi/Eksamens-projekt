extends CPUParticles2D

func _ready() -> void:
	$Timer.wait_time = lifetime

func _on_timer_timeout() -> void:
	queue_free()
