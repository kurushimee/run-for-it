extends CanvasLayer

@export var main: Node

@export var free_items: bool


func _ready() -> void:
  refetch_prices()
  for item in $Shop/PanelContainer/VBoxContainer.get_children():
    if item.name == "Label":
      continue
    item.main = main
    item.bought.connect(_on_bought)
    item.get_node("PostTransaction").price_changed.connect(refetch_prices)


func refetch_prices() -> void:
  for item in $Shop/PanelContainer/VBoxContainer.get_children():
    if item.name == "Label":
      continue
    if main.money.to_int() < item.price_money.to_int() and not free_items:
      item.modulate = Color("909090")
      item.mouse_filter = Control.MOUSE_FILTER_IGNORE
    else:
      item.modulate = Color.WHITE
      item.mouse_filter = Control.MOUSE_FILTER_PASS


func _on_game_end() -> void:
  $ShopMusic.play()
  $ShopMusic/AnimationPlayer.play("ost_fade_in")
  refetch_prices()


func _on_reset_game() -> void:
  $ShopMusic/AnimationPlayer.play("ost_fade_out")


func _on_bought(cost: Money) -> void:
  if free_items:
    return
  main.money.sub(cost)
  $Money.text = main.money.print()
  $Earned.text = "-" + cost.print()
  $Earned.modulate = Color.RED
  $Earned.reset()
  refetch_prices()
