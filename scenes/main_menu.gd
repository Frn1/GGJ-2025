extends Control

func _ready() -> void:
	get_viewport().gui_focus_changed.connect($UiFocusChange.play)
	if OS.has_feature("web"):
		$Items/Buttons/Quit.free()

func _on_play_pressed() -> void:
	# TODO: Encontrar una mejor manera de cargar el nivel
	# Como cambiar la escena hace que se libere todos los nodos actualmente
	# cargados, instancio la escena "game", la modifico y la vuelvo a empaquetar
	var template_game_scene = preload("res://scenes/game.tscn")
	var game = template_game_scene.instantiate()
	game.level_scene = preload("res://levels/level_1.tscn")
	var new_game_scene = PackedScene.new()
	new_game_scene.pack(game)
	TransitionController.change_to_scene(new_game_scene)

func _on_quit_pressed() -> void:
	get_tree().quit()

var music_tone_raised = false
var times_looped = 0

func _on_music_finished() -> void:
	# Don't loop more than 3 times on the menu
	if times_looped >= 3:
		return
	if music_tone_raised:
		$Music.pitch_scale = 1.00
		music_tone_raised = false
	else: 
		# Lower pitch by 1 semitone (according to Audacity)
		$Music.pitch_scale = 1.00 - 0.05613
		music_tone_raised = true
	times_looped += 1
	$Music.play()
