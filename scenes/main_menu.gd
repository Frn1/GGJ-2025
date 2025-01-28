extends Control

const GAME_SCENE_PATH = "res://scenes/game.tscn"
const LEVEL_SCENE_PATH = "res://levels/level_2_alt2.tscn"

func _ready() -> void:
	ResourceLoader.load_threaded_request(GAME_SCENE_PATH, "PackedScene")
	ResourceLoader.load_threaded_request(LEVEL_SCENE_PATH, "PackedScene")
	if OS.has_feature("web"):
		$Items/Buttons/Quit.free()

func _on_play_pressed() -> void:
	$Items.process_mode = Node.PROCESS_MODE_DISABLED
	$CutsceneTransition.play("transition")
	await $CutsceneTransition.animation_finished
	$Cutscene.animate()
	await $Cutscene.cutscene_done
	while (
		ResourceLoader.load_threaded_get_status(GAME_SCENE_PATH) == ResourceLoader.THREAD_LOAD_IN_PROGRESS
	and ResourceLoader.load_threaded_get_status(LEVEL_SCENE_PATH) == ResourceLoader.THREAD_LOAD_IN_PROGRESS):
			TransitionController.loading()
			await TransitionController.anim_player.animation_finished
	# TODO: Encontrar una mejor manera de cargar el nivel
	# Como cambiar la escena hace que se libere todos los nodos actualmente
	# cargados, instancio la escena "game", la modifico y la vuelvo a empaquetar
	var template_game_scene = ResourceLoader.load_threaded_get(GAME_SCENE_PATH)
	var game = template_game_scene.instantiate()
	game.level_scene = ResourceLoader.load_threaded_get(LEVEL_SCENE_PATH)
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
