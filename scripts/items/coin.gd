class_name Coin

extends Item


func interact() -> void:
	$PickupSound.play()
	$AnimatedSprite2D.hide()
	$AnimationPlayer.play("fade")

	var earned: int = randi_range(10, 40) * (main.speed / main.START_SPEED)
	main.earned += earned

	$AmountEarned.position.x += randi_range(-10, 10)
	$AmountEarned.position.y += randi_range(-10, 10)
	$AmountEarned.text = "+" + str(earned)
	$AmountEarned.show()
