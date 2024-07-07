extends CanvasLayer

# Time in seconds
var time: float
var max_time := 5.0

signal time_expired


func _ready() -> void:
	reset()


func _process(delta: float) -> void:
	time -= delta
	render_time()
	if time <= 0.0:
		reset()
		time_expired.emit()


func render_time() -> void:
	var minutes := clampi(floori(time / 60), 0, 99)
	var seconds := clampi(ceili(time - (minutes * 60)), 0, 59)
	var seconds_formatted := str(seconds) if seconds >= 10 else "0" + str(seconds)
	$TimeLabel.text = str(minutes) + ":" + seconds_formatted


func reset() -> void:
	time = max_time
	render_time()
	set_process(false)


func _on_start_game() -> void:
	set_process(true)
