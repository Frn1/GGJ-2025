extends CanvasLayer

var bg_bus_unpaused_db: float
var bg_2_bus_unpaused_db: float
@export_range(-60, 0) var bg_bus_paused_db: float = -6
@export_range(-60, 0) var bg_2_bus_paused_db: float = 0

# Separé esto a su propio script porque si no cuando se pausaba el juego, todo
# dejaba de responder (Ya que el process_mode era inherit)
func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("pause"):
		toggle_pause()

@onready var bg_bus_id = AudioServer.get_bus_index("BG")
@onready var bg_2_bus_id = AudioServer.get_bus_index("BG 2")

func _ready() -> void:
	AudioServer.set_bus_effect_enabled(bg_2_bus_id, 0, false)
	bg_bus_unpaused_db = AudioServer.get_bus_volume_db(bg_bus_id)
	bg_2_bus_unpaused_db = AudioServer.get_bus_volume_db(bg_2_bus_id)
	pass

func _notification(what):
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		if get_tree().paused == false:
			pause_game()

func toggle_pause():
	if get_tree().paused == false:
		pause_game()
	else:
		unpause_game()

var current_tweens: Array[Tween] = []

func pause_game():
	if get_tree().paused == true:
		return
	get_tree().paused = true
	$PauseMenu.mouse_filter = Control.MOUSE_FILTER_STOP
	$PauseMenu.show()
	for tween in current_tweens:
		tween.kill()
	current_tweens.clear()
	AudioServer.set_bus_effect_enabled(bg_2_bus_id, 0, true)
	AudioServer.set_bus_volume_db(bg_bus_id, bg_bus_paused_db)
	AudioServer.set_bus_volume_db(bg_2_bus_id, bg_2_bus_paused_db)
	AudioServer.get_bus_effect(bg_2_bus_id, 0).cutoff_hz = 400

func unpause_game():
	if get_tree().paused == false:
		return
	get_tree().paused = false
	$PauseMenu.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$PauseMenu.hide()
	for tween in current_tweens:
		tween.stop()
		tween.kill()
	current_tweens.clear()
	current_tweens.append(create_tween())
	current_tweens[-1].tween_method(func(value): AudioServer.set_bus_volume_db(bg_bus_id, value), AudioServer.get_bus_volume_db(bg_bus_id), bg_bus_unpaused_db, 0.5)
	
	current_tweens.append(create_tween())
	current_tweens[-1].tween_method(func(value): AudioServer.set_bus_volume_db(bg_2_bus_id, value), AudioServer.get_bus_volume_db(bg_2_bus_id), 0, 0.5)
	
	current_tweens.append(create_tween())
	current_tweens[-1].tween_method(AudioServer.get_bus_effect(bg_2_bus_id, 0).set_resonance, AudioServer.get_bus_effect(bg_2_bus_id, 0).resonance, 1.0, 2.0)
	
	current_tweens.append(create_tween())
	current_tweens[-1].tween_method(AudioServer.get_bus_effect(bg_2_bus_id, 0).set_cutoff, AudioServer.get_bus_effect(bg_2_bus_id, 0).cutoff_hz, 20500, 5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	current_tweens[-1].finished.connect(func(): AudioServer.set_bus_effect_enabled(bg_2_bus_id, 0, false))
