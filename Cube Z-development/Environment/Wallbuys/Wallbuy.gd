extends Area2D

export (String) var weapon

func _ready():
	pass
	

func _on_Wallbuy_body_entered(body):
	if body is KinematicBody2D and body.is_in_group("Player"):
		GlobalSignal.emit_signal("wallbuy_activated", true, body, self)

func _on_Wallbuy_body_exited(body):
	if body is KinematicBody2D and body.is_in_group("Player"):
		GlobalSignal.emit_signal("wallbuy_activated", false, body, self)
