extends "Actor.gd"

signal collided_with_item

onready var animated_sprite = $AnimatedSprite
onready var grab_ray = $GrabRay
onready var top_ray  = $TopGrabRay

# additional movement parameters
export (float, 0 , 1.0) var friction = 0.1
export (float, 0 , 1.0) var acceleration = 0.25
export (float, 0, 1.0) var top_speed_accel = 0.1
export (float, 0 , 1.0) var grab_friction = 1.0
export (float, 0, 1.0) var deceleration = 0.17
var jump_accel = 0.135
var speed_factor = 1.0

var is_on_wall = false
var is_at_corner = false

func get_input_grab():
    
    #implement up/down climbing mechanic
    if Input.is_action_pressed("move_up"):
        velocity.y = lerp(velocity.y, -(speed.y / 3.0), acceleration)
    elif Input.is_action_pressed("move_down"):
        velocity.y = lerp(velocity.y, (speed.y / 3.0), acceleration)
    else:
        velocity.y = lerp(velocity.y, 0, grab_friction)
        
func get_input_wall_jump(wall_check):
        #right wall grabbed
    if wall_check.normal == Vector2(-1,0):
        if Input.is_action_pressed("move_left"):
            velocity.y = lerp(velocity.y, -3.7 * speed.y, jump_accel)
    #left wall grabbed
    if wall_check.normal == Vector2(1,0): 
        if Input.is_action_pressed("move_right"):  
            velocity.y = lerp(velocity.y, -3.7 * speed.y, jump_accel)
            
func get_input_grab_over(wall_check):
    #implement up/down climbing mechanic

    var dir = 0
    #right wall grabbed
    if wall_check.normal == Vector2(-1,0):
        dir = 1
    elif wall_check.normal == Vector2(1,0):
        dir = -1
    
    #implement up/down climbing mechanic
    if Input.is_action_pressed("move_up"):
        velocity.y = lerp(velocity.y, -(speed.y / 5.0), acceleration)
        velocity.x += dir * (speed.x / 4.0)
    elif Input.is_action_pressed("move_down"):
        velocity.y = lerp(velocity.y, (speed.y / 2.0), acceleration)


    else:
        velocity.y = lerp(velocity.y, 0, grab_friction)
        
func _physics_process(delta: float) -> void:
    
    #setup raycasting
    var space_state = get_world_2d().direct_space_state
    var result = space_state.intersect_ray(grab_ray.global_position, grab_ray.global_position + grab_ray.cast_to, [self])
    var top_result = space_state.intersect_ray(top_ray.global_position, top_ray.global_position + top_ray.cast_to, [self])
    
    #if returned result is not empty, player is_on_wall
    if result.size() != 0:
        is_on_wall = true

    else:
        is_on_wall = false
        
    #if returned top_result is not empty, player is_at_corner
    if top_result.size() !=0:
        is_at_corner = true
    else:
        is_at_corner = false
        
    #check for valid result to use as weal check
    var wall_check = result
    if !is_on_wall:
        wall_check = top_result 
    #grab mechanic
    if (is_on_wall or is_at_corner) and Input.is_action_pressed("grab"):
        #climb up and down while grabbing
        get_input_grab()
        
        #implement wall_jump
        get_input_wall_jump(wall_check)
        
    #if at corner while grabbing
    if Input.is_action_pressed("grab") and (is_on_wall and top_result.size() == 0):
       #implement getting over corner
        get_input_grab_over(wall_check)
            
    #setup animations based on left/right movements
    if Input.is_action_just_pressed("move_right"):
        animated_sprite.play("run_right")
        grab_ray.cast_to = Vector2(25, 0)
        top_ray.cast_to = Vector2(25,0)
    elif Input.is_action_just_pressed("move_left"):
        animated_sprite.play("run_left")
        grab_ray.cast_to = Vector2(-25, 0)
        top_ray.cast_to = Vector2(-25,0)

    
    #implement  move character to left/right with 6 frame acceleration to top speed
    if Input.is_action_pressed("move_right"):
        animated_sprite.flip_h = false
        var increment = speed_factor * speed.x / 4.2
        velocity.x += increment
        if velocity.x >= (speed_factor * speed.x):
            velocity.x = speed_factor * speed.x
    elif Input.is_action_pressed("move_left"):
        animated_sprite.flip_h = true
        var increment = speed_factor * speed.x / 4.2
        velocity.x -= increment
        if velocity.x <= (speed_factor * -speed.x):
            velocity.x = speed_factor * -speed.x
    else:
        animated_sprite.play("idle_left")
        velocity.x = lerp(velocity.x, 0.0, deceleration)
    
    #implement jump
    if is_on_floor() and Input.is_action_just_pressed("jump"):
        velocity.y = lerp(velocity.y, 3.5 * -speed.y, jump_accel)
        
    #apply velocity to character
    velocity = move_and_slide(velocity, FLOOR_NORMAL)
    

