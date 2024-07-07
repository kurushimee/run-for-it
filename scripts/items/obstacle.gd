class_name Obstacle

extends Item


func interact() -> void:
	get_parent().end_game()
