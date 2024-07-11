extends HBoxContainer

@export var item_name: String
@export var price_string: String
@export var rarenesss_color: Color

var hovered := false
var price_money := Money.new()
var level: int
var main: Node

signal bought(cost: Money)


func _ready() -> void:
  $Name.modulate = rarenesss_color
  $Name.text = item_name
  price_money = Money.new(price_string)
  show_price()


func increase_level() -> void:
  level += 1
  $Level/Label.text = str(level)
  if level > 0 and level <= 2:
    $Level.modulate = Color("FDFEFE")
  if level > 2 and level <= 5:
    $Level.modulate = Color("27AE60")
  if level > 5 and level <= 10:
    $Level.modulate = Color("2471A3")
  if level > 10 and level <= 15:
    $Level.modulate = Color("7D3C98")
  if level > 15 and level <= 20:
    $Level.modulate = Color("F1C40F")
  if level > 20 and level <= 25:
    $Level.modulate = Color("D35400")
  if level > 25 and level <= 50:
    $Level.modulate = Color("7B241C")
  if level > 50 and level <= 100:
    $Level.modulate = Color("B3CA1F")
  if level > 100:
    $Level.modulate = Color("DC2367")


func show_price() -> void:
  $Price.text = price_money.print()


func _on_mouse_entered() -> void:
  hovered = true
  modulate = Color("cccccc")
  $Hover.play()


func _on_mouse_exited() -> void:
  hovered = false
  if main.money.to_int() >= price_money.to_int():
    modulate = Color.WHITE


func _on_gui_input(event: InputEvent) -> void:
  if not hovered:
    return
  if event.is_action_released("ui_press"):
    modulate = Color("cccccc")
    $Press.play()
    bought.emit(price_money)
    $PostTransaction.proceed(main)
    show_price()
    increase_level()
  elif event.is_action_pressed("ui_press"):
    modulate = Color("bbbbbb")
