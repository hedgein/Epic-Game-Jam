extends "Actor.gd"

signal collided_with_item

onready var animated_sprite = $AnimatedSprite
onready var raycast = $RayCast2D

# additional movement parameters
export (float, 0 , 1.0) var friction = 0.1
export (float, 0 , 1.0) var acceleration = 0.15
export (float, 0, 1.0) var top_speed_accel = 0.1
export (float, 0 , 1.0) var grab_friction = 1.0
export (float, 0, 1.0) var deceleration = 0.17
var jump_accel = 0.135
var speed_factor = 1.0

var is_on_wall = false

func get_input_grab():

    if Input.is_action_pressed("move_up"):
        velocity.y = lerp(velocity.y, -(speed.y / 2.0), acceleration)
        print(velocity.y)
    elif Input.is_action_pressed("move_down"):
        velocity.y = lerp(velocity.y, (speed.y / 2.0), acceleration)
        print(velocity.y)
    else:
        velocity.y = lerp(velocity.y, 0, grab_friction)
        
        

#    if dir != 0:
#        velocity.y = lerp(velocity.y, dir * (speed.y / 2.0), acceleration)
#    else:
#        

#func get_input_release(normal):
#    var dir = 0
#    if normal == Vector2(1,0): #if wall is grabbed to left
#        dir += 3
#    if normal == Vector2(-1, 0): #if wall is grabbed to right
#        dir -= 3
#
#    if dir != 0:
#        velocity.x = lerp(velocity.x, dir * speed, acceleration)
#    else:
#        velocity.x = lerp(velocity.x, 0, friction)

func _physics_process(delta: float) -> void:
    var space_state = get_world_2d().direct_space_state
    
    var result = space_state.intersect_ray(global_position, global_position + raycast.cast_to, [self])
    
    
    if result.size() != 0:
        is_on_wall = true
    else:
        is_on_wall = false
        
    if is_on_wall and Input.is_action_pressed("grab"):
        get_input_grab()

        # grab and interpret wall_collision normal
        #right wall grabbed
        if result.normal == Vector2(-1,0):
            if Input.is_action_pressed("move_left"):
                velocity.y = lerp(velocity.y, -4 * speed.y, jump_accel)
        #left wall grabbed
        if result.normal == Vector2(1,0): 
            if Input.is_action_pressed("move_right"):  
                velocity.y = lerp(velocity.y, -4 * speed.y, jump_accel)
                
    if Input.is_action_just_pressed("move_right"):
        print("run right")
        animated_sprite.flip_h = false
        animated_sprite.play("run_right")
        raycast.cast_to = Vector2(25, 0)
    elif Input.is_action_just_pressed("move_left"):
        animated_sprite.flip_h = true
        animated_sprite.play("run_left")
        raycast.cast_to = Vector2(-25, 0)
    if Input.is_action_just_released("move_right"):
        animated_sprite.play("idle_right")
    elif Input.is_action_just_released("move_left"):
        animated_sprite.play("idle_left")
    
    if Input.is_action_pressed("move_right"):
        var increment = speed_factor * speed.x / 4.2
        velocity.x += increment
        if velocity.x >= (speed_factor * speed.x):
            velocity.x = speed_factor * speed.x
    else:
        #animated_sprite.stop()
        velocity.x = lerp(velocity.x, 0.0, deceleration)
        
    
    if Input.is_action_pressed("move_left"):
        var increment = speed_factor * speed.x / 4.2
        velocity.x -= increment
        if velocity.x <= (speed_factor * -speed.x):
            velocity.x = speed_factor * -speed.x
    else:
        #animated_sprite.stop()
        velocity.x = lerp(velocity.x, 0.0, deceleration)
    
    if is_on_floor() and Input.is_action_just_pressed("jump"):
        velocity.y = lerp(velocity.y, 5 * -speed.y, jump_accel)
#    var direction := _get_input()
#    var is_jump_interrupted = Input.is_action_just_released("jump") and velocity.y < 0.0
#    velocity = calc_velocity(velocity, direction, speed, is_jump_interrupted)
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


