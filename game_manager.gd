extends Node

var points = 0
var health = 50
var loop_time = 180.0

# Called when the node enters the scene tree for the first time.
func _ready():
    SignalBus.connect("item_picked_up", self, "on_Item_picked_up")
    SignalBus.connect("player_reset", self, "on_Player_reset")

func on_Item_picked_up():
    points += 1
    if points == 3:
        SignalBus.emit_signal("item_complete")

func on_Player_reset():
    health -= 10
    if health <= 0:
        SignalBus.emit_signal("player_death")

