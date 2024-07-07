class_name Item

extends Area2D

var main: Node


# Called when player enters item's collider
func on_hit(body: Object) -> void:
	if body.name == "Player":
		interact()


# Removes the item
func remove() -> void:
	main.remove_obstacle(self)


# Custom item functionality on player collision
func interact() -> void:
	pass
