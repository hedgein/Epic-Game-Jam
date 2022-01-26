extends "Actor.gd"

signal collided_with_item

onready var animated_sprite = $AnimatedSprite

# additional movement parameters
export (float, 0 , 1.0) var friction = 0.1
export (float, 0 , 1.0) var acceleration = 0.1
export (float, 0, 1.0) var top_speed_accel = 0.1
export (float, 0 , 1.0) var grab_friction = 1.0
export (float, 0, 1.0) var deceleration = 0.17
var jump_accel = 0.135
var speed_factor = 1.2

func get_input_grab():
    #Setup blank direction
    var dir = 0.0
        
    if Input.is_action_pressed("move_up"):
        dir = -1.0
        velocity.y = lerp(velocity.y, dir * (speed.y / 2.0), acceleration)

    if Input.is_action_pressed("move_down"):
        dir =  1.0
        velocity.y = lerp(velocity.y, dir * (speed.y / 2.0), acceleration)
            
    if dir != 0:
        velocity.y = lerp(velocity.y, dir * (speed.y / 2.0), acceleration)
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

func _physics_process(delta: float) -> void:
    if Input.is_action_pressed("grab") and is_on_wall():
        get_input_grab()
        var wall_collision = get_last_slide_collision()
        
        # grab and interpret wall_collision normal
        #right wall grabbed
        if wall_collision.normal == Vector2(-1,0):
            if Input.is_action_pressed("move_left"):
                velocity.y = lerp(velocity.y, -4 * speed.y, jump_accel)
        #left wall grabbed
        if wall_collision.normal == Vector2(1,0): 
            if Input.is_action_pressed("move_right"):  
                velocity.y = lerp(velocity.y, -4 * speed.y, jump_accel)
                
        
        
    if Input.is_action_pressed("move_right"):
        animated_sprite.play("run_right")
        animated_sprite.flip_h = false
        var increment = speed_factor * speed.x / 4.2
        velocity.x += increment
        if velocity.x >= (speed_factor * speed.x):
            print("top speed reached")
            velocity.x = speed_factor * speed.x
        print(velocity.x)
    else:
        animated_sprite.play("idle_right")
        velocity.x = lerp(velocity.x, 0.0, deceleration)
        
    
    if Input.is_action_pressed("move_left"):
        animated_sprite.play("run_left")
        animated_sprite.flip_h = true
        var increment = speed_factor * speed.x / 4.2
        velocity.x -= increment
        if velocity.x <= (speed_factor * -speed.x):
            print("top speed reached")
            velocity.x = speed_factor * -speed.x
        print(velocity.x)
    else:
        animated_sprite.play("idle_left")
        velocity.x = lerp(velocity.x, 0.0, deceleration)
    
    if Input.is_action_just_pressed("jump"):
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


