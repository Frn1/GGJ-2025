extends Node2D

@export var level_scene: PackedScene

var level: Level
@onready var camera: Camera2D = $Camera

var spawns: Array = []

func _ready() -> void:
	level = level_scene.instantiate()
	add_child(level)
	
