extends Node2D

@export var level_scene: PackedScene
@export var player_scene: PackedScene = preload("res://objects/player.tscn")
@export var bubble_scene: PackedScene = preload("res://objects/bubble.tscn")
var level: Level

var spawns: Array = []

var player_0: Player
var player_1: Player

func spawn_random_bubble() -> void:
	const BUBBLE_SPAWN_SOURCE_ID: int = 1
	var spawn_coords = level.meta.get_used_cells_by_id(BUBBLE_SPAWN_SOURCE_ID, Vector2i(-1, -1))
	var coord = spawn_coords.pick_random()
	while spawn_coords.is_empty() == false:
		var pos = level.meta.map_to_local(coord)
		if $Bubbles.get_children().any(func (node: Node2D): return node.position == pos):
			spawn_coords.erase(coord)
			coord = spawn_coords.pick_random()
		else:
			var bubble: Node2D = bubble_scene.instantiate()
			bubble.position = pos
			$Bubbles.add_child(bubble)
			break
		
func spawn_player(number: int) -> void:
	const PLAYER_SPAWN_SOURCE_ID: int = 0
	var spawn_coords = level.meta.get_used_cells_by_id(PLAYER_SPAWN_SOURCE_ID, Vector2i(-1, -1), number)
	for coord in spawn_coords:
		var player: Player = player_scene.instantiate()
		var pos = level.meta.map_to_local(coord)
		player.number = number
		player.global_position = pos
		if number == 0:
			player_0 = player
		elif number == 1:
			player_1 = player
		add_child(player)

func _ready() -> void:
	level = level_scene.instantiate()
	add_child(level)
	spawn_player(0)
	spawn_player(1)
	spawn_random_bubble()

func _process(_delta: float) -> void:
	$UI/Game.player_0.text = str(player_0.score)
	$UI/Game.player_1.text = str(player_1.score)
