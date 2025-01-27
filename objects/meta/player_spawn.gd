class_name PlayerSpawn

extends Node2D

@export_range(0, 1) var player: int = 0

func _ready() -> void:
	if OS.is_debug_build() and OS.has_feature("movie") == false:
		visible = true
	else:
		visible = false
		for child in get_children():
			child.queue_free()
