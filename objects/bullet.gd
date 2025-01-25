class_name Bullet

extends Area2D

# Player who fired the bullet
var player: int = 0
# Angle the bullet travels at
var angle: float = 0
# Speed the bullet travels at
@export var speed: float = 500

func _physics_process(delta: float) -> void:
	var forward = Vector2.from_angle(angle)
	global_position += forward * delta * speed
