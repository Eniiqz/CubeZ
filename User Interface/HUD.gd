extends CanvasLayer

onready var Ammo = get_node("Ammo")
onready var ReserveAmmo = get_node("Reserve")

var Player


func set_player(new_player):
	if Player != new_player:
		Player = new_player

func make_connections():
	Player.connect("on_weapon_changed", self, "on_weapon_changed")
	Player.connect("on_weapon_fired", self, "on_weapon_fired")
	
func _ready():
	pass
	
func on_weapon_changed(new_weapon):
	update_hud("Ammo", new_weapon.current_ammo_in_mag)
	update_hud("Reserve", new_weapon.current_ammo_reserve)

func on_weapon_fired(weapon):
	update_hud("Ammo", weapon.current_ammo_in_mag)

func update_hud(node_name: String, new_value):
	print("called to update")
	var node = get_node_or_null(node_name)
	if node != null:
		node.text = String(new_value)
