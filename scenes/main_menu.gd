extends Control

func _ready() -> void:
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
