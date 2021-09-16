extends Node2D

const Player = preload("res://Player/Player.tscn")
const Zombie = preload("res://Zombie/Zombie.tscn")

onready var PlayerSpawnLocation = get_node("PlayerSpawnLocation")

export (int) var current_round
export (int) var zombies_left
export (int) var zombies_in_round

func _ready():
	GlobalSignal.connect("on_zombie_death", self, "on_zombie_death")
	GlobalSignal.connect("on_player_death", self, "on_player_death")
	current_round = 1
	spawn_player()
	
func calculate_zombies_in_round(desired_round: int) -> int:
	var starting_num = 6
	if desired_round > 1:
		return starting_num + starting_num * desired_round
	else:
		return starting_num
	
func on_zombie_death(object):
	if object.is_in_group("Zombie"):
		zombies_left -= 1
		print(zombies_left)

func on_player_death(player):
	print(player.name, " has died.")

func spawn_player():
	var player = Player.instance()
	add_child(player)
	player.set_global_position(PlayerSpawnLocation.get_global_position())
