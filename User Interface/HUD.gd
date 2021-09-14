extends CanvasLayer

onready var Ammo = get_node("Ammo")
onready var ReserveAmmo = get_node("Reserve")
onready var Weapon = get_node("Weapon")

var Player
var CurrentWeapon

func _ready():
	GlobalSignal.connect("weapon_ammo_changed", self, "on_weapon_ammo_changed")
	GlobalSignal.connect("weapon_changed", self, "on_weapon_changed")
	GlobalSignal.connect("weapon_reloaded", self, "on_weapon_reloaded")

func set_player(new_player):
	if Player != new_player:
		Player = new_player
		
func on_weapon_reloaded(weapon):
	print(weapon, " reloaded")
	if weapon == CurrentWeapon:
		update_hud("Ammo", weapon.current_ammo_in_mag)
		update_hud("Reserve", weapon.current_ammo_reserve)

func on_weapon_changed(previous_weapon, new_weapon):
	print(previous_weapon, Weapon)
	CurrentWeapon = new_weapon
	Weapon.text = CurrentWeapon.name
	print("weapon changed to: ", new_weapon.name)
	update_hud("Ammo", new_weapon.current_ammo_in_mag)
	update_hud("Reserve", new_weapon.current_ammo_reserve)

func on_weapon_ammo_changed(weapon, new_ammo, new_reserve):
	if weapon == CurrentWeapon:
		update_hud("Ammo", new_ammo)
		update_hud("Reserve", new_reserve)

func update_hud(node_name: String, new_value):
	var node = get_node_or_null(node_name)
	if node != null:
		node.text = String(new_value)
