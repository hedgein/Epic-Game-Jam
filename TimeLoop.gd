extends Node

signal restart

# Declare member variables here. Examples:
onready var timerLabel = $CanvasLayer/HBoxContainer/timerLabel
onready var timeLoop = $timeLoop

var total = GameManager.loop_time


# Called when the node enters the scene tree for the first time.
func _ready():
    timeLoop.start(total)
    timerLabel.text = "START"
    


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
    var timeLeft = timeLoop.get_time_left()
    var timeInMins = timeLeft / 60
    var timeInSeconds = timeLeft as int % 60
    var format_string
    if (timeInSeconds  < total and timeInSeconds > 10): 
        format_string = "%d:%d"
    elif (timeInSeconds < 10):
        format_string = "%d:0%d"
    else:
        format_string = "%d:%d"
    
    timerLabel.text =  format_string % [timeInMins, timeInSeconds]


func _on_timeLoop_timeout():
    emit_signal("restart")
