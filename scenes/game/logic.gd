class_name Game

extends Node2D

@export var level_scene: PackedScene
@export var player_scene: PackedScene = preload("res://objects/player.tscn")
@export var bubble_scene: PackedScene = preload("res://objects/bubble.tscn")
var level: Level

@export var bubbles_needed_to_win: int = 10

# Used to avoid repeating spawn positions
var last_bubble_coords: Array = []

var player_0: Player
var player_1: Player

@onready var pause_menu = $UI/PauseMenu
@onready var game_ui = $UI/GameUI
@onready var winner_ui = $UI/WinnerUI
@onready var countdown_ui = $UI/CountdownUI
@onready var countdown_timer = $CountdownTimer
@onready var bubbles = $Bubbles
@onready var combat_music = $CombatMusic
@onready var ambient_music = $AmbientMusic

signal bubble_collected

func spawn_random_bubble() -> void:
	const BUBBLE_SPAWN_SOURCE_ID: int = 1
	var spawn_coords = level.meta.get_used_cells_by_id(BUBBLE_SPAWN_SOURCE_ID, Vector2i(-1, -1))
	# Remove the last bubble spawn coords
	for coord in last_bubble_coords:
		spawn_coords.erase(coord)
	var coord = spawn_coords.pick_random()
	while spawn_coords.is_empty() == false:
		var pos = level.meta.map_to_local(coord)
		if bubbles.get_children().any(func (node: Node2D): return node.position == pos):
			spawn_coords.erase(coord)
			coord = spawn_coords.pick_random()
		else:
			last_bubble_coords.push_back(coord)
			while last_bubble_coords.size() > 2:
				last_bubble_coords.pop_front()
			var bubble: Node2D = bubble_scene.instantiate()
			bubble.position = pos
			bubbles.add_child.call_deferred(bubble)
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

func go_to_menu() -> void:
	var volume_tween = create_tween()
	volume_tween.tween_method(combat_music.set_volume_db, 0.0, -80.0, 0.5)
	volume_tween.tween_method(ambient_music.set_volume_db, 0.0, -80.0, 0.5)
	TransitionController.change_to_file("res://scenes/main_menu.tscn")

func player_won(number: int) -> void:
	winner_ui.format_text(number + 1)
	var menu_timer = Timer.new()
	# We add the timer to the tree to ensure it doesn't get paused later
	winner_ui.add_child(menu_timer)
	menu_timer.one_shot = true
	menu_timer.timeout.connect(go_to_menu)
	menu_timer.start(2)
	get_tree().paused = true

func _ready() -> void:
	level = level_scene.instantiate()
	add_child(level)
	spawn_random_bubble()
	spawn_random_bubble()
	spawn_player(0)
	spawn_player(1)
	player_0.disable_input = true
	player_1.disable_input = true
	await TransitionController.transition_done
	combat_music.play()
	countdown_timer.start()
	countdown_ui.play_countdown()
	await countdown_timer.timeout
	player_0.disable_input = false
	player_1.disable_input = false
	

func _process(_delta: float) -> void:
	if player_0.bubbles == bubbles_needed_to_win:
		player_won(0)
	elif player_1.bubbles == bubbles_needed_to_win:
		player_won(1)
	game_ui.player_0.text = str(player_0.bubbles)
	game_ui.player_1.text = str(player_1.bubbles)
