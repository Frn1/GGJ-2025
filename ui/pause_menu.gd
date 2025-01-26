extends Node

signal unpause
signal go_to_menu

func _on_resume_pressed() -> void:
	unpause.emit()


func _on_main_menu_pressed() -> void:
	go_to_menu.emit()
