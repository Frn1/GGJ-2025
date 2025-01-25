class_name Player

extends CharacterBody2D

@export_range(0, 1) var number = 0 

@export var speed = 300.0
@export var jump_velocity = 400.0

@export var bubbles: int = 0

signal bubble_collected
signal bubble_lost

func _ready() -> void:
	$Sprite.sprite_frames = load("res://objects/player/{0}/animations.tres".format([number]))
	if number == 1:
		$Sprite.flip_h = true
	$Sprite.play()

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if Input.is_action_just_pressed("jump_p" + str(number)) and is_on_floor() and not is_on_ceiling():
		velocity.y = -jump_velocity
	
	var direction := Input.get_axis("move_left_p" + str(number), "move_right_p" + str(number))
	if direction:
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
	
	if direction > 0:
		$Sprite.flip_h = false
	elif direction < 0:
		$Sprite.flip_h = true
	
	if direction == 0:
		$Sprite.animation = "idle"
	else: 
		$Sprite.animation = "running"
	
	move_and_slide()


func _on_bubble_collected() -> void:
	bubbles += 1

func _on_bubble_lost() -> void:
	bubbles -= 1
