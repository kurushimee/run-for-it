extends CharacterBody2D

const JUMP_VELOCITY := -1500.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")


func _physics_process(delta: float) -> void:
	if is_on_floor():
		if not get_parent().game_running:
			$AnimatedSprite2D.play("idle")
			return
		if Input.is_action_just_pressed("jump"):
			velocity.y = JUMP_VELOCITY
			$JumpSound.play()
		else:
			$AnimatedSprite2D.play("run")
	else:
		velocity.y += gravity * delta
		$AnimatedSprite2D.play("jump")

	move_and_slide()
