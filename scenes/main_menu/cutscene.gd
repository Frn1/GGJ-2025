extends Control

signal cutscene_done

func animate() -> void:
	$CutsceneAudio.play()
	$SubViewport/AnimatedSprite2D.play("default")
	await $SubViewport/AnimatedSprite2D.animation_finished
	cutscene_done.emit()

func _ready() -> void:
	$SubViewport/AnimatedSprite2D.frame = 0
