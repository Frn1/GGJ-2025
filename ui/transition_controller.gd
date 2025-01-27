extends CanvasLayer

signal transition_done

@onready var anim_player = $AnimationPlayer
@onready var original_bus_layout = AudioServer.generate_bus_layout()

func _ready() -> void:
	anim_player.current_animation = "RESET"

func enter_transition():
	get_tree().paused = true
	anim_player.play("enter")
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	
func loading():
	anim_player.play("loading")

func exit_transition():
	# Set the bus layout to reset any modifications done by the last scene
	AudioServer.set_bus_layout(original_bus_layout)
	anim_player.play("exit")
	await anim_player.animation_finished
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().paused = false
	transition_done.emit()

func change_to_file(path: String) -> void:
	if anim_player.is_playing():
		push_error("Scene changed requested in the middle of another scene change!")
	enter_transition()
	await anim_player.animation_finished
	ResourceLoader.load_threaded_request(path, "PackedScene", true)
	while ResourceLoader.load_threaded_get_status(path) == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		loading()
		await anim_player.animation_finished
	get_tree().change_scene_to_packed(ResourceLoader.load_threaded_get(path))
	exit_transition()

func change_to_scene(scene: PackedScene) -> void:
	if anim_player.is_playing():
		push_error("Scene changed requested in the middle of another scene change!")
	enter_transition()
	await anim_player.animation_finished
	loading()
	get_tree().change_scene_to_packed(scene)
	await anim_player.animation_finished
	exit_transition()

func change_to_scene_no_start(scene: PackedScene) -> void:
	if anim_player.is_playing():
		push_error("Scene changed requested in the middle of another scene change!")
	loading()
	await anim_player.animation_finished
	get_tree().change_scene_to_packed(scene)
	exit_transition()
