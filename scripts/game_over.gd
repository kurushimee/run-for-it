extends CanvasLayer


func _on_game_end() -> void:
	$ShopMusic.play()
	$ShopMusic/AnimationPlayer.play("ost_fade_in")


func _on_reset_game() -> void:
	$ShopMusic/AnimationPlayer.play("ost_fade_out")
