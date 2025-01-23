extends Node2D

@export var level_scene: PackedScene

var level: Level
@onready var camera: Camera2D = $Camera

var spawns: Array = []

var is_paused = false

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
	

func _input(event):
	if event.is_action_pressed("ui_cancel"):  # Esc para pausar
		toggle_pause()

func toggle_pause():
	is_paused = !is_paused
	print("a")
	get_tree().paused = is_paused
	$PauseMenu.visible = is_paused

func _on_ResumeButton_pressed():
	toggle_pause()

func _on_MainMenuButton_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main-menu.tscn")
