extends CanvasLayer

func change_to_scene(scene: PackedScene) -> void:
	if $AnimationPlayer.is_playing():
		push_error("Scene changed requested in the middle of another scene change!")
	get_tree().paused = true
	$AnimationPlayer.play("enter")
	await $AnimationPlayer.animation_finished
	get_tree().change_scene_to_packed(scene)
	get_tree().paused = true
	$AnimationPlayer.play("exit")
	await $AnimationPlayer.animation_finished
	get_tree().paused = false
