extends HBoxContainer

@export var item_name: String
@export var item_price: int
signal bought(cost: int)

var hovered := false

var main: Node


func _ready() -> void:
	$Name.text = item_name
	$Price.text = "$" + str(item_price)


func _on_mouse_entered() -> void:
	hovered = true
	modulate = Color("cccccc")
	$Hover.play()


func _on_mouse_exited() -> void:
	hovered = false
	if main.money >= item_price:
		modulate = Color.WHITE


func _on_gui_input(event: InputEvent) -> void:
	if not hovered:
		return

	if event.is_action_released("ui_press"):
		modulate = Color("cccccc")
		$Press.play()
		$PostTransaction.proceed(main)
		bought.emit(item_price)
	elif event.is_action_pressed("ui_press"):
		modulate = Color("bbbbbb")
