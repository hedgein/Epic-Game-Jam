extends Node2D

var _player: KinematicBody2D = null

onready var extra: Node2D = $Extra


# Called when the node enters the scene tree for the first time.
func _ready():
    for n in extra.get_children():
        if n.is_in_group("player"):
            _player = n
        elif n.is_in_group("enemy"):
            n.visibility_enabler.connect("screen_entered", self, "_on_Enemy_screen_enetered", [n])


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#    pass
