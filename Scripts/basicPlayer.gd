extends KinematicBody2D

signal collided_with_item

#set up basic movement parameters
export (int) var speed = 325
export (int) var jump_speed = -400
export (int) var gravity = 1000

#additional movement parameters
export (float, 0 , 1.0) var friction = 0.1
export (float, 0 , 1,0) var acceleration = 0.25


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

func _physics_process(delta):
    get_input()
    velocity.y += gravity * delta
    velocity = move_and_slide(velocity, Vector2.UP)
    if Input.is_action_pressed("move_up"):
        if is_on_floor():
            velocity.y = jump_speed
         
