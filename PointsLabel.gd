extends Label


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var format_string = "%d/3"

# Called when the node enters the scene tree for the first time.
func _ready():
    SignalBus.connect("item_picked_up", self, "on_item_picked_up")
    text = format_string % [GameManager.points]

func on_item_picked_up():
    text = format_string % [GameManager.points] 
