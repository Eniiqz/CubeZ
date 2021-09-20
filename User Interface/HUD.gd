extends CanvasLayer

onready var Ammo = get_node("Ammo")
onready var ReserveAmmo = get_node("Reserve")
onready var Weapon = get_node("Weapon")
onready var Health = get_node("Health")
onready var RoundCounter = get_node("RoundCounter")

var Player
var CurrentWeapon

func _ready():
	GlobalSignal.connect("weapon_ammo_changed", self, "on_weapon_ammo_changed")
	GlobalSignal.connect("weapon_changed", self, "on_weapon_changed")
	GlobalSignal.connect("weapon_reloaded", self, "on_weapon_reloaded")
	GlobalSignal.connect("health_changed", self, "on_health_changed")
	GlobalSignal.connect("round_ended", self, "on_round_end")

func set_player(new_player):
	yield(self, "ready")
	if Player != new_player:
		Player = new_player
		Health.set_value(float(Player.health))

func on_round_end(next_round):
	update_hud("RoundCounter", next_round)

func on_weapon_reloaded(weapon):
	if weapon == CurrentWeapon:
		update_hud("Ammo", weapon.current_ammo_in_mag)
		update_hud("Reserve", weapon.current_ammo_reserve)

func on_weapon_changed(previous_weapon, new_weapon):
	CurrentWeapon = new_weapon
	Weapon.text = CurrentWeapon.name
	update_hud("Ammo", new_weapon.current_ammo_in_mag)
	update_hud("Reserve", new_weapon.current_ammo_reserve)

func on_weapon_ammo_changed(weapon, new_ammo, new_reserve):
	if weapon == CurrentWeapon:
		update_hud("Ammo", new_ammo)
		update_hud("Reserve", new_reserve)

func on_health_changed(object, new_health):
	if object == Player:
		Health.set_value(float(new_health))


func update_hud(node_name: String, new_value):
	var node = get_node_or_null(node_name)
	if node != null:
		node.text = String(new_value)
