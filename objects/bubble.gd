extends Area2D

var collected: bool = false

func _init():
	scale = Vector2.ZERO

func _on_body_entered(body: Node2D) -> void:
	if collected:
		return
	if body is Player:
		collected = true
		body.bubble_collected.emit()
		$Sprite.animation_finished.connect(queue_free)
		$Sprite.animation = "pop"
