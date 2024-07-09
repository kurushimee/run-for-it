extends Node

# Cat variant scenes
@export var cat_variants: Array[PackedScene]
@export var blue_cat: PackedScene
@export var green_cat: PackedScene
@export var pink_cat: PackedScene

# Cat variant buffs
const CAT_BONUS := 2
const GREEN_CAT_BONUS := 3
const PINK_CAT_BONUS := 5
const BLUE_CAT_BONUS := 10

# Regular cats
var cats_spawned: Array[Cat]
var cats_owned: int
# Green cats
var green_cats_spawned: Array[Cat]
var green_cats_owned: int
# Pink cats
var pink_cats_spawned: Array[Cat]
var pink_cats_owned: int
# Blue cats
var blue_cats_spawned: Array[Cat]
var blue_cats_owned: int

@export var item_variants: Array[PackedScene]
var items_spawned: Array[Item]
var last_item_spawned: Item

# Initial positions
const PLAYER_START_POS := Vector2i(150, 444)
const CAM_START_POS := Vector2i(576, 324)

# Score
var score: int
const SCORE_MODIFIER := 10
var high_score: int

# Cash
var money: int
var max_money: int
var earned: int

# Player moving speed
var speed: float
const START_SPEED := 10.0
const MAX_SPEED := 25.0
const PROSTO_SPEED := 100
const SPEED_MODIFIER := 5000

var screen_size: Vector2i
var game_running: bool

var difficulty: int
const MAX_DIFFICULTY := 2

var ground_height: int
var ground_scale: int

signal reset_game
signal start_game
signal game_end


func _ready() -> void:
	screen_size = get_viewport().size
	ground_height = $Ground/Sprite2D.texture.get_height()
	ground_scale = $Ground/Sprite2D.scale.y
	$GameOver/Button.pressed.connect(new_game)
	new_game()


func _process(delta: float) -> void:
	# Show in-game menu when <ESC> is pressed
	if Input.is_action_just_pressed("menu"):
		$Menu.show()
		get_tree().paused = true
		return

	# Start the game if received input to do so, otherwise halt the game loop
	if not game_running:
		if Input.is_action_pressed("jump"):
			game_running = true
			$HUD/StartLabel.hide()
			start_game.emit()
		else:
			return

	speed = (
		clamp(START_SPEED + score / SPEED_MODIFIER, START_SPEED, MAX_SPEED) * PROSTO_SPEED * delta
	)
	adjust_difficulty()

	generate_item()

	# Move the player forward
	$Player.position.x += speed
	$Camera2D.position.x += speed

	# Update the score
	score += speed
	show_score()

	# Reset ground position to keep it in bounds
	if $Camera2D.position.x - $Ground.position.x > screen_size.x * 1.5:
		$Ground.position.x += screen_size.x

	# Remove the items_spawned that have gone off screen
	for obstacle in items_spawned:
		if obstacle.position.x < ($Camera2D.position.x - screen_size.x):
			remove_item(obstacle)


func new_game() -> void:
	# Reset variables
	speed = START_SPEED
	score = 0
	earned = 0
	show_score()
	get_tree().paused = false
	game_running = false
	difficulty = 0

	generate_cat()
	# Delete all items_spawned
	for obstacle in items_spawned:
		obstacle.queue_free()
	items_spawned.clear()
	last_item_spawned = null

	# Reset nodes
	$Player.position = PLAYER_START_POS
	$Player.velocity = Vector2i(0, 0)
	$Camera2D.position = CAM_START_POS
	$Ground.position = Vector2i(0, 0)

	# Reset HUD
	$HUD/StartLabel.show()
	$GameOver.hide()
	$RunningMusic.play()
	$RunningMusic/AnimationPlayer.play("ost_fade_in")
	reset_game.emit()


func show_score() -> void:
	$HUD/ScoreLabel.text = "SCORE: " + str(score / SCORE_MODIFIER)
	check_high_score()


func check_high_score() -> void:
	if score > high_score:
		high_score = score
		$HUD/HighScoreLabel.text = "HIGHSCORE: " + str(high_score / SCORE_MODIFIER)


func generate_item() -> void:
	if not items_spawned.is_empty():
		if last_item_spawned != null:
			if last_item_spawned.position.x >= score + randi_range(300, 500):
				return
	var item_type := item_variants[randi() % item_variants.size()]
	var item: Item

	var max_items := difficulty + 1
	for i in randi() % max_items + 1:
		item = item_type.instantiate()

		# Get item's sprite pixel lengths
		var item_height: int = item.get_node("Sprite2D").texture.get_height()
		var item_scale: Vector2i = item.get_node("Sprite2D").scale
		# Calculate the position accordingly
		var item_x: int = screen_size.x + $Player.position.x + (i * 100) + (speed / MAX_SPEED) * 150
		var item_y: int = (
			screen_size.y
			- (ground_height * ground_scale)
			- (item_height * item_scale.y / 2)
			+ (2 * item_scale.y)
		)

		add_item(item, item_x, item_y)


func add_item(item: Item, x: int, y: int) -> void:
	item.position = Vector2i(x, y)
	item.main = self
	item.body_entered.connect(item.on_hit)
	last_item_spawned = item
	add_child(item)
	items_spawned.append(item)


func remove_item(item: Item):
	items_spawned.erase(item)
	item.queue_free()


func adjust_difficulty() -> void:
	difficulty = clamp(score / SPEED_MODIFIER, 0, MAX_DIFFICULTY)


func end_game() -> void:
	get_tree().paused = true
	game_running = false
	$RunningMusic/AnimationPlayer.play("ost_fade_out")

	# Calculate how much player gets from just running
	var final_score: int = score / SCORE_MODIFIER / 10
	# Add speed bonus to the ran amount
	var run_reward: int = final_score * (speed / START_SPEED)
	earned += run_reward
	if earned < money:
		earned *= 1 + (1 - earned / money)
	money += (
		earned
		* clamp(cats_owned, 1, 999)
		* clamp(green_cats_owned * GREEN_CAT_BONUS, 1, 999)
		* clamp(pink_cats_owned * PINK_CAT_BONUS, 1, 999)
		* clamp(blue_cats_owned * BLUE_CAT_BONUS, 1, 999)
	)

	$GameOver/Earned.text = "+" + str(earned) + "$"
	$GameOver/Earned.modulate = Color.GREEN
	$GameOver/Earned.reset()
	$GameOver/Money.text = str(money) + "$"
	$GameOver.show()
	game_end.emit()


func generate_cat() -> void:
	if green_cats_spawned.size() < green_cats_owned:
		for i in green_cats_owned - green_cats_spawned.size():
			green_cats_spawned.append(add_cat(green_cat))
	if pink_cats_spawned.size() < pink_cats_owned:
		for i in pink_cats_owned - pink_cats_spawned.size():
			pink_cats_spawned.append(add_cat(pink_cat))
	if blue_cats_spawned.size() < blue_cats_owned:
		for i in blue_cats_owned - blue_cats_spawned.size():
			blue_cats_spawned.append(add_cat(blue_cat))
	if cats_spawned.size() < cats_owned:
		for i in cats_owned - cats_spawned.size():
			var cat_type = cat_variants[randi() % cat_variants.size()]
			cats_spawned.append(add_cat(cat_type))


func add_cat(cat_type: PackedScene) -> Cat:
	var cat: Cat = cat_type.instantiate()
	$Camera2D.add_child(cat)

	cat.global_position.x = $Player.position.x - randi_range(45, PLAYER_START_POS.x)
	cat.global_position.y = PLAYER_START_POS.y

	return cat
