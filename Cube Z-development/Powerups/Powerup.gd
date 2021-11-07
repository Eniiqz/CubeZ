extends Area2D
class_name Powerup

onready var DespawnTimer = get_node("DespawnTimer")

export var type: String


func _ready():
	DespawnTimer.start()
	GlobalSignal.emit_signal("on_powerup_spawned", self)
	DespawnTimer.connect("timeout", self, "despawn")
	
func despawn():
	queue_free()
	pass

func _on_Powerup_body_entered(body):
	if body is KinematicBody2D and body.is_in_group("Player"):
		GlobalSignal.emit_signal("on_powerup_touched", self, body)
		despawn()
