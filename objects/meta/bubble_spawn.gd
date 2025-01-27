extends Node2D

func _ready() -> void:
	if OS.is_debug_build() and OS.has_feature("movie") == false:
		visible = true
	else:
		visible = false
		for child in get_children():
			child.queue_free()
