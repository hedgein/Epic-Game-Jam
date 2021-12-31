extends KinematicBody2D

signal collided_with_item

var speed = 60

func _physics_process(delta):
    var x_input = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
    var y_input = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
    var velocity = Vector2(x_input, y_input) * 60
    #move_and_slide(velocity)
    var collision = move_and_collide(velocity )
    if collision:
        emit_signal("collided_with_item")
         
