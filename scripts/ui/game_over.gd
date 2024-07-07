extends CanvasLayer

@export var main: Node

@export var free_items: bool


func _ready() -> void:
	recalculate_available_items()
	for item in $Shop/VBoxContainer.get_children():
		item.main = main
		item.bought.connect(_on_bought)


func recalculate_available_items() -> void:
	for item in $Shop/VBoxContainer.get_children():
		if main.money < item.item_price and not free_items:
			item.modulate = Color("909090")
			item.mouse_filter = Control.MOUSE_FILTER_IGNORE
		else:
			item.modulate = Color.WHITE
			item.mouse_filter = Control.MOUSE_FILTER_PASS


func _on_game_end() -> void:
	$ShopMusic.play()
	$ShopMusic/AnimationPlayer.play("ost_fade_in")
	recalculate_available_items()


func _on_reset_game() -> void:
	$ShopMusic/AnimationPlayer.play("ost_fade_out")


func _on_bought(cost: int) -> void:
	if free_items:
		return
	main.money -= cost
	$Money.text = "$" + str(main.money)
	$Earned.text = "-" + str(cost) + "$"
	$Earned.modulate = Color.RED
	$Earned.reset()
	recalculate_available_items()
