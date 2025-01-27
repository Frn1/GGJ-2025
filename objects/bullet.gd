class_name Bullet

extends Area2D

# Player who fired the bullet
var player: Player
# Angle the bullet travels at
var angle: float = 0
# Speed the bullet travels at
@export var speed: float = 500

func _physics_process(delta: float) -> void:
	var forward = Vector2.from_angle(angle)
	global_position += forward * delta * speed

var hit = false

func _on_body_entered(body: Node2D) -> void:
	print(body)
	if hit:
		return
	if body is Player:
		if body == player:
			return
		#if body.bubbles > 0:
			#player.bubble_gained.emit()
		body.hit.emit()
	hit = true
	queue_free()
