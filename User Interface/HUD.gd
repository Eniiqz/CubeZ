extends CanvasLayer

onready var Ammo = get_node("Ammo")
onready var ReserveAmmo = get_node("Reserve")

func _ready():
	pass
	
func update_hud(node_name: String, new_value):
	print("called to update")
	var node = get_node_or_null(node_name)
	if node != null:
		node.text = new_value
