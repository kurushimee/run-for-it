extends Node

@export var available_obstacles: Array[PackedScene]
var obstacles: Array[Area2D]

# Initial positions
const PLAYER_START_POS := Vector2i(150, 444)
const CAM_START_POS := Vector2i(576, 324)

# Score
var score: int
const SCORE_MODIFIER := 10
var high_score: int

# Player moving speed
var speed: float
const START_SPEED := 12.0
const MAX_SPEED := 20.0
const PROSTO_SPEED := 100
const SPEED_MODIFIER := 5000

var screen_size: Vector2i
var game_running: bool

var difficulty: int
const MAX_DIFFICULTY := 2

var last_obstacle: Area2D

var ground_height: int
var ground_scale: int


func _ready() -> void:
	screen_size = get_window().size
	ground_height = $Ground/Sprite2D.texture.get_height()
	ground_scale = $Ground/Sprite2D.scale.y
	$GameOver/Button.pressed.connect(new_game)
	new_game()


func _process(delta: float) -> void:
	if not game_running:
		if Input.is_action_pressed("jump"):
			game_running = true
			$HUD/StartLabel.hide()
		else:
			return

	speed = (
		clamp(START_SPEED + score / SPEED_MODIFIER, START_SPEED, MAX_SPEED) * PROSTO_SPEED * delta
	)
	adjust_difficulty()

	generate_obstacle()

	# Move the player forward
	$Player.position.x += speed
	$Camera2D.position.x += speed

	# Update the score
	score += speed
	show_score()

	# Reset ground position to keep it in bounds
	if $Camera2D.position.x - $Ground.position.x > screen_size.x * 1.5:
		$Ground.position.x += screen_size.x

	# Remove the obstacles that have gone off screen
	for obstacle in obstacles:
		if obstacle.position.x < ($Camera2D.position.x - screen_size.x):
			remove_obstacle(obstacle)


func new_game() -> void:
	# Reset variables
	speed = START_SPEED
	score = 0
	show_score()
	get_tree().paused = false
	game_running = false
	difficulty = 0

	# Delete all obstacles
	for obstacle in obstacles:
		obstacle.queue_free()
	obstacles.clear()
	last_obstacle = null

	# Reset nodes
	$Player.position = PLAYER_START_POS
	$Player.velocity = Vector2i(0, 0)
	$Camera2D.position = CAM_START_POS
	$Ground.position = Vector2i(0, 0)

	# Reset HUD
	$HUD/StartLabel.show()
	$GameOver.hide()
	$RunningMusic/AnimationPlayer.play("fade_in")


func show_score() -> void:
	$HUD/ScoreLabel.text = "SCORE: " + str(score / SCORE_MODIFIER)
	check_high_score()


func check_high_score() -> void:
	if score > high_score:
		high_score = score
		$HUD/HighScoreLabel.text = "HIGHSCORE: " + str(high_score / SCORE_MODIFIER)


func generate_obstacle() -> void:
	if not obstacles.is_empty():
		if last_obstacle != null:
			if last_obstacle.position.x >= score + randi_range(300, 500):
				return
	var obstacle_type := available_obstacles[randi() % available_obstacles.size()]
	var obstacle: Area2D

	var max_obstacles := difficulty + 1
	for i in randi() % max_obstacles + 1:
		obstacle = obstacle_type.instantiate()

		# Get obstacle's sprite pixel lengths
		var obstacle_height: int = obstacle.get_node("Sprite2D").texture.get_height()
		var obstacle_scale: Vector2i = obstacle.get_node("Sprite2D").scale
		# Calculate the position accordingly
		var obstacle_x: int = (
			screen_size.x + $Player.position.x + (i * 100) + (speed / MAX_SPEED) * 100
		)
		var obstacle_y: int = (
			screen_size.y
			- (ground_height * ground_scale)
			- (obstacle_height * obstacle_scale.y / 2)
			+ (2 * obstacle_scale.y)
		)

		add_obstacle(obstacle, obstacle_x, obstacle_y)


func add_obstacle(obstacle: Area2D, x: int, y: int) -> void:
	obstacle.position = Vector2i(x, y)
	obstacle.body_entered.connect(hit_obstacle)
	last_obstacle = obstacle
	add_child(obstacle)
	obstacles.append(obstacle)


func remove_obstacle(obstacle: Area2D):
	obstacles.erase(obstacle)
	obstacle.queue_free()


func hit_obstacle(body: Object) -> void:
	if body.name == "Player":
		end_game()


func adjust_difficulty() -> void:
	difficulty = clamp(score / SPEED_MODIFIER, 0, MAX_DIFFICULTY)


func end_game() -> void:
	get_tree().paused = true
	game_running = false
	$GameOver.show()
	$RunningMusic/AnimationPlayer.play("fade_out")
