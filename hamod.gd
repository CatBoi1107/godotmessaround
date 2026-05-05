extends CharacterBody2D

@onready var AnimatedSprite: AnimatedSprite2D = $AnimatedSprite2D
@export var speed = 300.0
@export var gravity = 4500
const acceleration = 800.0
const deceleration = 500.0

func _physics_process(delta: float) -> void:
	var direction = Vector2.ZERO
	
	var is_falling = velocity.y > 0 and not is_on_floor()
	var is_idle = velocity == Vector2.ZERO
	var is_moving = not is_idle

	if is_idle:
		AnimatedSprite.play("Idle")
	else:
		AnimatedSprite.play("Run")
	if not is_on_floor():
		velocity.y += gravity * delta

	if Input.is_action_pressed("move_right"):
		direction.x += 1
		up_direction = Vector2(-1, 0)
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
		up_direction = Vector2(1, 0)
	if Input.is_action_pressed("move_down"):
		direction.y += 1
		up_direction = Vector2(0, -1)
	if Input.is_action_pressed("move_up"):
		direction.y -= 1
		up_direction = Vector2(0, 1)
		
	if not is_on_floor():
		velocity += -up_direction * gravity * delta

	if direction != Vector2.ZERO:
		direction = direction.normalized()
		velocity = velocity.move_toward(direction * speed, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, deceleration * delta)
		
	if get_position_delta().x > 10:
		position.x = -10
	elif get_position_delta().x < -10:
		position.x = 10

	move_and_slide()
	apply_floor_snap()

func _ready():
	AnimatedSprite.play("Idle")
	var spawn_point = get_parent().get_node("SpawnPoint2D")
	if spawn_point:
		global_position = spawn_point.global_position
