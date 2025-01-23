extends Node2D


func _on_PlayButton_pressed():
	# Cargar la escena principal
	print("hola")
	get_tree().change_scene_to_file("res://Scenes/game.tscn")
	print("hello")

func _on_QuitButton_pressed():
	# Salir del juego
	get_tree().quit()
