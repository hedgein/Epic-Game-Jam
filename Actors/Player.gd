extends "Actor.gd"

signal collided_with_item

# additional movement parameters
export (float, 0 , 1.0) var friction = 0.1
export (float, 0 , 1.0) var acceleration = 0.25
export (float, 0 , 1.0) var grab_friction = 1.0

func get_input_grab():
	var dir = 0 
	if Input.is_action_pressed("move_up"):
		dir -=1
	if Input.is_action_pressed("move_down"):
		dir += 1
	
	if dir != 0:
		velocity.y = lerp(velocity.y, dir * (speed / 2), acceleration)
	else:
		velocity.y = lerp(velocity.y, 0, grab_friction)

func get_input_release(normal):
	var dir = 0
	if normal == Vector2(1,0): #if wall is grabbed to left
		dir += 3
	if normal == Vector2(-1, 0): #if wall is grabbed to right
		dir -= 3

	if dir != 0:
		velocity.x = lerp(velocity.x, dir * speed, acceleration)
	else:
		velocity.x = lerp(velocity.x, 0, friction)

func _physics_process(_delta: float) -> void:
	if Input.is_action_pressed("grab") and is_on_wall():
		get_input_grab()

	var direction := _get_input()
	var is_jump_interrupted = Input.is_action_just_released("jump") and velocity.y < 0.0
	velocity = calc_velocity(velocity, direction, speed, is_jump_interrupted)
	velocity = move_and_slide(velocity, FLOOR_NORMAL)
	
func _get_input() -> Vector2:
	var x := Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	var y := (
		-Input.get_action_strength("jump")
		if is_on_floor() and Input.is_action_just_pressed("jump")
		else 0.0
	)
	return Vector2(x, y)

func calc_velocity(
	velocity: Vector2, direction: Vector2, speed: Vector2, is_jump_interrupted: bool
	) -> Vector2:
	velocity.x = speed.x * direction.x

	if direction.y != 0.0:
		velocity.y = speed.y * direction.y
	if is_jump_interrupted:
		velocity.y = 0.0
	return velocity
