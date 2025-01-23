extends Node2D

@export var level_scene: PackedScene

var level: Level
@onready var camera: Camera2D = $Camera

var spawns: Array = []

func _ready() -> void:
	level = level_scene.instantiate()
	add_child(level)
	for child in level.get_children():
		if child is CameraLimit:
			match child.camera_limit_side:
				CameraLimit.CameraLimitSide.LEFT:
					camera.limit_left = child.global_position.x
				CameraLimit.CameraLimitSide.TOP:
					camera.limit_top = child.global_position.y
				CameraLimit.CameraLimitSide.BOTTOM:
					camera.limit_bottom = child.global_position.y
				CameraLimit.CameraLimitSide.RIGHT:
					camera.limit_right = child.global_position.x
