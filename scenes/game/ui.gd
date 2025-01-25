extends CanvasLayer

# Separé esto a su propio script porque si no cuando se pausaba el juego, todo
# dejaba de responder (Ya que el process_mode era inherit)

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("pause"):
		toggle_pause()

func toggle_pause():
	if get_tree().paused == false:
		pause_game()
	else:
		unpause_game()

func pause_game():
	get_tree().paused = true
	$PauseMenu.mouse_filter = Control.MOUSE_FILTER_STOP
	$PauseMenu.show()

func unpause_game():
	get_tree().paused = false
	$PauseMenu.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$PauseMenu.hide()
