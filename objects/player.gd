class_name Player

extends CharacterBody2D

@export_range(0, 1) var number = 0 

@export var speed = 300.0
@export var jump_velocity = 400.0

@export var bubbles: int = 0

@export var bullet_scene: PackedScene = preload("res://objects/bullet.tscn")

signal bubble_collected
signal bubble_lost

@onready var sprite = $Sprite
@onready var bullet_spawn = $Sprite/BulletSpawn

var flipped: bool = false
var was_on_floor: bool = is_on_floor()

func _ready() -> void:
	sprite.sprite_frames = load("res://objects/player/{0}/animations.tres".format([number]))
	if number == 1:
		flipped = true
		sprite.scale.x = -1

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	if is_on_floor() and was_on_floor == false:
		sprite.play("landing")
		
	if Input.is_action_just_pressed("jump_p" + str(number)) and is_on_floor():
		velocity.y = -jump_velocity
		sprite.play("jump")
	
	var direction: float = Input.get_axis("move_left_p" + str(number), "move_right_p" + str(number))
	if direction:
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
	
	if direction > 0:
		flipped = false
		sprite.scale.x = 1
	elif direction < 0:
		flipped = true
		sprite.scale.x = -1
	
	was_on_floor = is_on_floor()
	
	move_and_slide()
	
	var shoot = Input.is_action_just_pressed("attack_p" + str(number))
	if shoot:
		var bullet: Bullet = bullet_scene.instantiate()
		get_parent().add_child(bullet)
		bullet.global_position = bullet_spawn.global_position
		if flipped:
			bullet.angle = PI
	
	if (sprite.animation == "jump" or sprite.animation == "landing" or sprite.animation.ends_with("shoot")) and sprite.is_playing():
		pass
	else:
		if is_zero_approx(velocity.y):
			if is_zero_approx(direction):
				sprite.play("idle")
			else:
				sprite.play("running")
		elif velocity.y > 0:
			sprite.play("midair")
		elif velocity.y < 0:
			sprite.play("falling")
		
		if shoot:
			sprite.animation += "_shoot"

func _on_bubble_collected() -> void:
	bubbles += 1

func _on_bubble_lost() -> void:
	bubbles -= 1
