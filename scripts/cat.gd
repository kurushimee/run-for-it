class_name Cat

extends Node2D


func _process(_delta: float) -> void:
	if not get_node("../..").game_running:
		$AnimatedSprite2D.play("idle")
	else:
		$AnimatedSprite2D.play("run")

	if $Timer.is_stopped():
		$Timer.start(randf_range(3.0, 10.0))


func _on_timer_timeout() -> void:
	$MeowSound.play()
