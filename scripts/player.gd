extends CharacterBody2D

const INPUT_BUFFER := 0.1  # time in seconds
var buffer_timer := 0.0
var buffer := false

const JUMP_VELOCITY := -1500.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")


func _physics_process(delta: float) -> void:
	# Play idle animation and unqueue any jumps if the game is paused
	if not get_parent().game_running:
		buffer = false
		$AnimatedSprite2D.play("idle")
		return

	# Activate the input buffer if trying to jump
	if Input.is_action_just_pressed("jump"):
		buffer_timer = 0.0
		buffer = true
	elif buffer_timer > INPUT_BUFFER:
		buffer = false

	if is_on_floor():
		# Jump if button pressed within buffer time
		if buffer and buffer_timer <= INPUT_BUFFER:
			velocity.y = JUMP_VELOCITY
			$JumpSound.play()
			buffer = false
		else:
			$AnimatedSprite2D.play("run")
	else:
		velocity.y += gravity * delta
		$AnimatedSprite2D.play("jump")

	move_and_slide()
	buffer_timer += delta
