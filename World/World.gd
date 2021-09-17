extends Node2D

const Player = preload("res://Player/Player.tscn")
const Zombie = preload("res://Zombie/Zombie.tscn")

var Powerups = {
	 "MaxAmmo": preload("res://Powerups/MaxAmmo/MaxAmmo.tscn"),
}


onready var PlayerSpawnLocation = get_node("PlayerSpawnLocation")
onready var RoundEnd = get_node("RoundEnd")

export (int) var current_round

export (int) var active_zombies
export (int) var zombies_in_round
export (int) var zombies_spawned_in_round

func DEBUG(player):
	player.invincible = true

func _ready():
	GlobalSignal.connect("on_zombie_death", self, "on_zombie_death")
	GlobalSignal.connect("on_player_death", self, "on_player_death")
	GlobalSignal.connect("on_zombie_spawned", self, "on_zombie_spawned")
	spawn_player()
	change_round()
	
func change_round():
	if zombies_spawned_in_round == zombies_in_round:
		RoundEnd.start()
		yield(RoundEnd, "timeout")
		current_round += 1
		zombies_in_round = calculate_zombies_in_round(current_round)
		zombies_spawned_in_round = 0

func calculate_zombies_in_round(desired_round: int) -> int:
	var starting_num = 6
	if desired_round > 1:
		return starting_num + (starting_num * desired_round)
	else:
		return starting_num

func calculate_drop_chance():
	pass

func on_zombie_death(object):
	if object.is_in_group("Zombie"):
		
		active_zombies -= 1
		if zombies_spawned_in_round == zombies_in_round and active_zombies == 0:
			print("changing round")
			GlobalSignal.emit_signal("round_ended", current_round + 1)
			change_round()

func on_zombie_spawned(zombie):
	pass

func on_player_death(player):
	print(player.name, " has died.")

func spawn_player():
	var player = Player.instance()
	add_child(player)
	player.set_global_position(PlayerSpawnLocation.get_global_position())
	DEBUG(player)
