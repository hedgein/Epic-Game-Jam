extends Area2D

signal next_level

func _on_Exit_body_entered(body:Node):
	# print(body)
	if "Player" in body.to_string() and body.is_class("KinematicBody2D"):
		emit_signal("next_level")
