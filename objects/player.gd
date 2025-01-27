class_name Player

extends CharacterBody2D

@export_range(0, 1) var number = 0 

@export var bullet_scene: PackedScene = preload("res://objects/bullet.tscn")

@export var speed = 300.0
@export var jump_velocity = 400.0

@export var disable_input: bool = false
@export var bubbles: int = 0

signal bubble_gained
signal hit

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var bullet_spawn = $Sprite/BulletSpawn
@onready var reload_timer = $ReloadTimer

var flipped: bool = false
var was_on_floor: bool = is_on_floor()
var can_shoot = true
var was_hit = false

func _ready() -> void:
	sprite.sprite_frames = load("res://objects/player/{0}/animations.tres".format([number]))
	if number == 1:
		flipped = true
		sprite.scale.x = -1

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
		if was_hit:
			velocity.x *= -0.25
		
	if is_on_floor() and not was_on_floor:
		sprite.play("landing")
		
	if Input.is_action_just_pressed("jump_p" + str(number)) and is_on_floor() and not disable_input:
		velocity.y = -jump_velocity
		sprite.play("jump")
	
	var direction: float = Input.get_axis("move_left_p" + str(number), "move_right_p" + str(number))
	if not disable_input and sprite.animation != "hit":
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
	
	var has_shot = Input.is_action_just_pressed("attack_p" + str(number)) and not disable_input
	
	if was_hit:
		sprite.play("hit")
	elif sprite.sprite_frames.get_animation_loop(sprite.animation) == false and sprite.is_playing():
		# If the animation doesn't loop we should not interrupt it with another animation
		pass
	elif disable_input:
		sprite.play("idle")
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
		
		if has_shot and can_shoot:
			sprite.animation += "_shoot"
	
	if has_shot:
		shoot()
	
	if was_hit:
		was_hit = false

func shoot() -> void:
	if not can_shoot:
		return
	var bullet: Bullet = bullet_scene.instantiate()
	get_parent().add_child(bullet)
	bullet.player = self
	bullet.global_position = bullet_spawn.global_position
	if flipped:
		bullet.angle = PI
	sprite.modulate = Color(0.7, 0.7, 0.7)
	can_shoot = false
	reload_timer.start()

func _on_bubble_gained() -> void:
	bubbles += 1

func _on_hit() -> void:
	if bubbles > 0:
		bubbles -= 1
	was_hit = true

func _on_reload_timer_timeout() -> void:
	can_shoot = true
	sprite.modulate = Color.WHITE
