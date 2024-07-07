class_name Coin

extends Item


func interact() -> void:
	$PickupSound.play()
	$AnimatedSprite2D.hide()
	$AnimationPlayer.play("fade")

	var earned: int = randi_range(25, 50) * (main.speed / main.START_SPEED)
	earned *= (
		clamp(main.cats_max, 1, 999)
		* clamp(main.green_max * main.GREEN_UP, 1, 999)
		* clamp(main.pink_max * main.PINK_UP, 1, 999)
		* clamp(main.blue_max * main.BLUE_UP, 1, 999)
	)
	var run_reward: int = main.calculate_run_reward()
	if earned + run_reward < main.max_money:
		earned *= 1 + (1 - (earned + run_reward) / main.max_money)
	main.earned += earned

	$AmountEarned.position.x += randi_range(-10, 10)
	$AmountEarned.position.y += randi_range(-10, 10)
	$AmountEarned.text = "+" + str(earned)
	$AmountEarned.show()
