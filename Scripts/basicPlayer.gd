extends KinematicBody2D

signal collided_with_item

#set up basic movement parameters
export (int) var speed = 325
export (int) var jump_speed = -400
export (int) var gravity = 1000

#additional movement parameters
export (float, 0 , 1.0) var friction = 0.1
export (float, 0 , 1.0) var acceleration = 0.25
export (float, 0 , 1.0) var grab_friction = 1.0


var velocity = Vector2.ZERO

func get_input():
    var dir = 0
    if Input.is_action_pressed("move_right"):
        dir += 1
    if Input.is_action_pressed("move_left"):
        dir -= 1
    if dir != 0:
        velocity.x = lerp(velocity.x, dir * speed, acceleration)
    else:
        velocity.x = lerp(velocity.x, 0, friction)

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
    #if wall is grabbed to left
    if normal == Vector2(1,0):
        dir += 3
    #if wall is grabbed to right
    if normal == Vector2(-1, 0):
        dir -= 3
    if dir != 0:
        velocity.x = lerp(velocity.x, dir * speed, acceleration)
    else:
        velocity.x = lerp(velocity.x, 0, friction)
    velocity.y = jump_speed 
func _physics_process(delta):
    if Input.is_action_pressed("grab"):
        if is_on_wall():
            get_input_grab()
    else: 
        get_input()
    velocity.y += gravity * delta
    velocity = move_and_slide(velocity, Vector2.UP)
    if (Input.is_action_just_released("grab") && Input.is_action_pressed("move_up")):
        if is_on_wall():
            get_input_release(get_last_slide_collision().normal)
    elif Input.is_action_pressed("move_up"):
        if is_on_floor():
            velocity.y = jump_speed
         
