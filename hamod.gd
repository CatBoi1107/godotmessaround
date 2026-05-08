extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@export var speed = 300.0
@export var gravity = 1500.0 
@export var acceleration = 1200.0
@export var friction = 1000.0
@export var direction = Vector2.ZERO
@export var jump_strength = -1000
@export var dash_strength = 700
# Ini buat double jump, klo mau single jump set jadi 1 aja
@export var max_jump = 2
@export var time_to_heal = 5
@export var dash_cooldown = 3

var last_dash
var current_jump = 0
var idle_time = 0

func _physics_process(delta: float) -> void:
	var is_floating = not is_on_floor()
	var is_horizontallyIdle = velocity.x == 0
	var is_verticallyIdle = velocity.y == 0
	var is_facing_left = velocity.x < 0
	var is_facing_right = velocity.x > 0
	#Kalo lagi ga di floor, apply gravity
	
	if is_floating:
		velocity.y += gravity * delta

	# Fetch horizontal direction
	direction.x = Input.get_axis("press_a", "press_d")
	
	if is_on_floor():
		current_jump = 0
	#Lompat
	if Input.is_action_just_pressed("press_space"):
		if current_jump < max_jump:
			velocity.y = jump_strength
			current_jump += 1
	
	# Dash mechanic hll yeah
	if Input.is_action_just_pressed("press_e") and is_on_floor():
		velocity.x = direction.x * dash_strength
	
	# Horizontal Movement sama Friction
	if direction.x != 0:
		velocity.x = move_toward(velocity.x, direction.x * speed, acceleration * delta)
		animated_sprite.flip_h = (velocity.x < 0) # Flip sprite based on direction
		animated_sprite.play("Run")
	else:
		velocity.x = move_toward(velocity.x, 0, friction * delta)
		if velocity.y == 0 and animated_sprite.animation != "Regen": # Only play idle if not jumping/falling
			animated_sprite.play("Idle")
			
	# Idle time Calculation
	if velocity == Vector2.ZERO and is_on_floor():
		idle_time += delta
	else:
		idle_time = 0
		
	# Regen animation if idle for long enoguh
	if idle_time >= time_to_heal and animated_sprite.animation != "Regen":
		animated_sprite.play("Regen")
		
		pass

	move_and_slide()

func _ready():
	animated_sprite.play("Idle")
	direction = Vector2.ZERO
	var spawn_point = get_parent().get_node_or_null("SpawnPoint2D")
	if spawn_point:
		global_position = spawn_point.global_position
