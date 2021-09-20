extends Node2D

const Player = preload("res://Player/Player.tscn")
const Zombie = preload("res://Zombie/Zombie.tscn")

var Powerups = {
	"MaxAmmo": preload("res://Powerups/MaxAmmo/MaxAmmo.tscn"),
	"Instakill": preload("res://Powerups/Instakill/Instakill.tscn")
}


onready var PlayerSpawnLocation = get_node("PlayerSpawnLocation")
onready var RoundEnd = get_node("RoundEnd")
onready var InstakillTimer = get_node("InstakillTimer")

export (int) var current_round
export (int) var current_zombie_health
export (int) var active_zombies
export (int) var zombies_in_round
export (int) var zombies_spawned_in_round



export (int) var powerup_chance = (50) + 1 # denominator, so like 1/50, use 50, do not change "+ 1"
export (bool) var instakill_active = false
func DEBUG(player):
	player.invincible = true

func _ready():
	randomize()
	GlobalSignal.connect("on_zombie_death", self, "on_zombie_death")
	GlobalSignal.connect("on_player_death", self, "on_player_death")
	GlobalSignal.connect("on_zombie_spawned", self, "on_zombie_spawned")
	GlobalSignal.connect("on_powerup_touched", self, "on_powerup_touched")
	InstakillTimer.connect("timeout", self, "_disable_instakill")
	current_zombie_health = 50
	spawn_player()
	change_round()
	
func change_round():
	if zombies_spawned_in_round == zombies_in_round:
		RoundEnd.start()
		yield(RoundEnd, "timeout")
		current_round += 1
		current_zombie_health += 25
		if current_round == 1:
			current_zombie_health = 50
		zombies_in_round = calculate_zombies_in_round(current_round)
		zombies_spawned_in_round = 0

func calculate_zombies_in_round(desired_round: int) -> int:
	var starting_num = 6
	if desired_round > 1:
		return starting_num + (starting_num * desired_round)
	else:
		return starting_num

func calculate_drop_chance(object_position):
	var random_number = randi() % powerup_chance
	var comparison_number = randi() % powerup_chance
	if comparison_number == random_number:
		var keys = Powerups.keys()
		var get_random_index = randi() % keys.size() + 1
		var random_powerup = keys[get_random_index - 1]
		var new_powerup = Powerups[random_powerup].instance()
		add_child(new_powerup)
		new_powerup.set_global_position(object_position)

func on_zombie_death(object):
	if object.is_in_group("Zombie"):
		calculate_drop_chance(object.get_global_position())
		active_zombies -= 1
		if zombies_spawned_in_round == zombies_in_round and active_zombies == 0:
			GlobalSignal.emit_signal("round_ended", current_round + 1)
			change_round()

func on_zombie_spawned(zombie):
	pass

func on_player_death(player):
	print(player.name, " has died.")

func on_powerup_touched(powerup, player):
	if powerup.name == "MaxAmmo":
		for _player in get_tree().get_nodes_in_group("Player"):
			for weapon in _player.get_weapons():
				weapon.current_ammo_reserve = weapon.default_ammo_reserve
				GlobalSignal.emit_signal("weapon_ammo_changed", weapon, weapon.current_ammo_in_mag, weapon.current_ammo_reserve)
	elif powerup.name == "Instakill":
		InstakillTimer.start()
		instakill_active = true
		for zombie in get_tree().get_nodes_in_group("Zombie"):
			zombie.health = 1

func _disable_instakill():
	print("instakill over")
	instakill_active = false
	for zombie in get_tree().get_nodes_in_group("Zombie"):
		zombie.health = current_zombie_health

func spawn_player():
	var player = Player.instance()
	add_child(player)
	player.set_global_position(PlayerSpawnLocation.get_global_position())
	#DEBUG(player)
