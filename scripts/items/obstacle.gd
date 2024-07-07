class_name Obstacle

extends Item


func interact() -> void:
	get_node("../Player/HitSound").play()
	get_parent().end_game()
