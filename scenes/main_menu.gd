extends Control

func _ready() -> void:
	if OS.has_feature("web"):
		$Items/Buttons/Quit.free()

func _on_play_pressed() -> void:
	const game_scene_path = "res://scenes/game.tscn"
	const level_scene_path = "res://levels/level_2_alt2.tscn"
	ResourceLoader.load_threaded_request(game_scene_path)
	ResourceLoader.load_threaded_request(level_scene_path)
	$Items.process_mode = Node.PROCESS_MODE_DISABLED
	$CutsceneTransition.play("transition")
	await $CutsceneTransition.animation_finished
	$Cutscene.animate()
	await $Cutscene.cutscene_done
	while (
		ResourceLoader.load_threaded_get_status(game_scene_path) == ResourceLoader.THREAD_LOAD_IN_PROGRESS
	and ResourceLoader.load_threaded_get_status(level_scene_path) == ResourceLoader.THREAD_LOAD_IN_PROGRESS):
			TransitionController.loading()
			await TransitionController.anim_player.animation_finished
	# TODO: Encontrar una mejor manera de cargar el nivel
	# Como cambiar la escena hace que se libere todos los nodos actualmente
	# cargados, instancio la escena "game", la modifico y la vuelvo a empaquetar
	var template_game_scene = ResourceLoader.load_threaded_get(game_scene_path)
	var game = template_game_scene.instantiate()
	game.level_scene = ResourceLoader.load_threaded_get(level_scene_path)
	var new_game_scene = PackedScene.new()
	new_game_scene.pack(game)
	TransitionController.change_to_scene_no_start(new_game_scene)

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
