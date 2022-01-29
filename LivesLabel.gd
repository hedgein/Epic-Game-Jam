extends Label


# Called when the node enters the scene tree for the first time.
func _ready():
    
    text = str(GameManager.health)
    SignalBus.connect("player_reset", self, "on_player_reset")
    
func on_player_reset():
    text = str(GameManager.health)
    


