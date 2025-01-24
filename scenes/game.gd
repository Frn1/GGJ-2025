extends Node2D

@export var level_scene: PackedScene
@export var player_scene: PackedScene = preload("res://objects/player.tscn")

var level: Level
@onready var camera: Camera2D = $Camera

var spawns: Array = []

func spawn_player(number: int) -> void:
	const PLAYER_SPAWN_SOURCE_ID: int = 0
	var spawn_coords = level.meta.get_used_cells_by_id(PLAYER_SPAWN_SOURCE_ID, Vector2i(-1, -1), number)
	for coord in spawn_coords:
		var player: Player = player_scene.instantiate()
		var pos = level.meta.map_to_local(coord)
		player.number = number
		player.position = pos
		add_child(player)

func _ready() -> void:
	level = level_scene.instantiate()
	add_child(level)
	spawn_player(0)
	print()
