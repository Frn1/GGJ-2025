class_name CameraLimit

extends Node2D

enum CameraLimitSide {
	LEFT,
	TOP,
	BOTTOM,
	RIGHT
}

@export var camera_limit_side: CameraLimitSide = CameraLimitSide.LEFT

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
