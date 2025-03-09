class_name Game

extends Node2D

@export var level_scene: PackedScene
@export var player_scene: PackedScene = preload("res://objects/player.tscn")
@export var bubble_scene: PackedScene = preload("res://objects/bubble.tscn")
var level: Level

@export var bubbles_needed_to_win: int = 15
# How many bubbles should be in the level at the same time
@export var bubbles_at_the_same_time: int = 8

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
@onready var bubble_ammount_timers = $BubbleAmountTimers
@onready var combat_music = $CombatMusic
@onready var ambient_music = $AmbientMusic
@onready var game_timer = $GameTimer
@onready var exit_anim = $ExitAnimation

signal bubble_collected

const MAIN_MENU_SCENE_PATH = "res://scenes/main_menu.tscn"

func spawn_random_bubble() -> void:
	if bubbles.get_child_count() > bubbles_at_the_same_time:
		return
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
			while last_bubble_coords.size() > bubbles_at_the_same_time:
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
		player.number = number
		player.name = "Player" + str(number)
		var pos = level.meta.map_to_local(coord)
		player.global_position = pos
		if number == 0:
			player_0 = player
		elif number == 1:
			player_1 = player
		add_child(player)

func go_to_menu() -> void:
	exit_anim.play("exit")
	TransitionController.change_to_scene(ResourceLoader.load_threaded_get(MAIN_MENU_SCENE_PATH))

func player_won(winner: int) -> void:
	exit_anim.play("battle_end")
	winner_ui.show_result(winner)
	var menu_timer = Timer.new()
	# We add the timer to the tree to ensure it doesn't get paused later
	winner_ui.add_child(menu_timer)
	menu_timer.one_shot = true
	menu_timer.timeout.connect(TransitionController.change_to_scene.bindv(
		[ResourceLoader.load_threaded_get(MAIN_MENU_SCENE_PATH)]
	))
	menu_timer.start(3)
	game_timer.paused = true
	player_0.disable_input = true
	player_1.disable_input = true
	get_tree().paused = true

var timer_ran = false

func calculate_time_to_show() -> String:
	if game_timer.is_stopped():
		if timer_ran: return "0"
		else: 
			if game_timer.wait_time > 99: return "99"
			else: return str(int(ceil(game_timer.wait_time)))
	else:
		timer_ran = true
	if game_timer.wait_time > 99:
		return str(int(floor(lerp(0, 99, game_timer.time_left / game_timer.wait_time))))
	else:
		return str(int(floor(game_timer.time_left)))

func _ready() -> void:
	ResourceLoader.load_threaded_request(MAIN_MENU_SCENE_PATH, "PackedScene")
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	game_ui.timer.text = calculate_time_to_show()
	level = level_scene.instantiate()
	add_child(level)
	for i in range(bubbles_at_the_same_time):
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
	ambient_music.process_mode = Node.PROCESS_MODE_ALWAYS
	combat_music.process_mode = Node.PROCESS_MODE_ALWAYS
	player_0.disable_input = false
	player_1.disable_input = false
	for timer in bubble_ammount_timers.get_children():
		if timer is Timer:
			# Ensure these timers only trigger once
			timer.one_shot = true
			timer.timeout.connect(
				func():
					bubbles_at_the_same_time = int(str(timer.name))
			)
			timer.start()
	game_timer.start()

func _process(_delta: float) -> void:
	if player_0.bubbles == bubbles_needed_to_win:
		player_won(0)
	elif player_1.bubbles == bubbles_needed_to_win:
		player_won(1)
	game_ui.player_0.text = str(player_0.bubbles)
	game_ui.player_1.text = str(player_1.bubbles)
	game_ui.timer.text = calculate_time_to_show()

func _on_game_timer_timeout() -> void:
	if player_0.bubbles == bubbles_needed_to_win or player_0.bubbles > player_1.bubbles:
		player_won(0)
	elif player_1.bubbles == bubbles_needed_to_win or player_1.bubbles > player_0.bubbles:
		player_won(1)
	else:
		player_won(-1)
