extends CanvasLayer

signal transition_done

@onready var anim_player = $AnimationPlayer
@onready var original_bus_layout = AudioServer.generate_bus_layout()

func _ready() -> void:
	anim_player.current_animation = "RESET"

func change_to_file(path: String) -> void:
	change_to_scene(load(path))

func change_to_scene(scene: PackedScene) -> void:
	if anim_player.is_playing():
		push_error("Scene changed requested in the middle of another scene change!")
	get_tree().paused = true
	# Set the bus layout to reset any modifications done by the last scene
	AudioServer.set_bus_layout(original_bus_layout)
	anim_player.play("enter")
	await anim_player.animation_finished
	get_tree().change_scene_to_packed(scene)
	get_tree().paused = true
	anim_player.play("exit")
	await anim_player.animation_finished
	get_tree().paused = false
	transition_done.emit()
