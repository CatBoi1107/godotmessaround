
extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@export var speed = 300.0
@export var gravity = 1500.0 
@export var acceleration = 1200.0
@export var friction = 1000.0
@export var direction = Vector2.ZERO
@export var jump_strength = -1000
# Ini buat double jump, klo mau single jump set jadi 1 aja
@export var max_jump = 2
@export var time_to_heal = 5

var currentJump = 0
var idle_time = 0

func _physics_process(delta: float) -> void:
	var is_floating = not is_on_floor()
	var is_horizontallyIdle = velocity.x == 0
	var is_verticallyIdle = velocity.y == 0
	#Kalo lagi ga di floor, apply gravity
	
	if is_floating:
		velocity.y += gravity * delta

	# Fetch horizontal direction
	direction.x = Input.get_axis("press_a", "press_d")
	
	if is_on_floor():
		currentJump = 0
	#Lompat
	if Input.is_action_just_pressed("press_space"):
		if currentJump < max_jump:
			velocity.y = jump_strength
			currentJump += 1
	
	# Horizontal Movement sama Friction
	if direction.x != 0:
		velocity.x = move_toward(velocity.x, direction.x * speed, acceleration * delta)
		animated_sprite.flip_h = (direction.x < 0) # Flip sprite based on direction
		animated_sprite.play("Run")
	else:
		velocity.x = move_toward(velocity.x, 0, friction * delta)
		if velocity.y == 0 and animated_sprite.animation != "Regen": # Only play idle if not jumping/falling
			animated_sprite.play("Idle")
			
	if velocity == Vector2.ZERO and is_on_floor():
		idle_time += delta
	else:
		idle_time = 0
		
	if idle_time >= time_to_heal and animated_sprite.animation != "Regen":
		animated_sprite.play("Regen")

	if not is_on_floor():
		pass

	move_and_slide()

func _ready():
	animated_sprite.play("Idle")
	direction = Vector2.ZERO
	var spawn_point = get_parent().get_node_or_null("SpawnPoint2D")
	if spawn_point:
		global_position = spawn_point.global_position
