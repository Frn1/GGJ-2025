extends Area2D

var collected: bool = false

@onready var game: Game = get_tree().current_scene

func _on_body_entered(body: Node2D) -> void:
	if collected:
		return
	if body is Player:
		collected = true
		game.bubble_collected.emit()
		body.bubble_gained.emit()
		$Sprite.animation_finished.connect(queue_free)
		$Sprite.animation = "pop"
