extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
    pass # Replace with function body.




func _on_Firefly_body_entered(body):
    print("signal emitted")
    SignalBus.emit_signal("player_reset")
