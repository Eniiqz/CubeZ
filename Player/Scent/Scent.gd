extends Node2D

var player

func _ready():
	$Expire.connect("timeout", self, "remove_scent")
	
func remove_scent():
	player.scent_trail.erase(self)
	queue_free()
