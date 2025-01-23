class_name Player

extends CharacterBody2D

@export_range(0, 1) var player = 0 

@export var speed = 300.0
@export var jump_velocity = 400.0

@export var score: int = 0

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if Input.is_action_just_pressed("jump_p" + str(player)) and is_on_floor():
		velocity.y = -jump_velocity
	
	var direction := Input.get_axis("move_left_p" + str(player), "move_right_p" + str(player))
	if direction:
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
	
	move_and_slide()
