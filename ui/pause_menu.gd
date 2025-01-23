extends Node

signal unpause

func _on_resume_pressed() -> void:
	unpause.emit()
