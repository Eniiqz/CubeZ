extends Node2D

const Player = preload("res://Player/Player.tscn")
const Zombie = preload("res://Zombie/Zombie.tscn")

export (int) var current_round
export (int) var zombies_left
export (int) var zombies_in_round

func _ready():
	GlobalSignal.connect("on_death", self, "on_object_death")
	current_round = 1
	spawn_player()
	
func calculate_zombies_in_round(desired_round: int) -> int:
	var starting_num = 6
	return starting_num * desired_round
	
func on_object_death(object):
	if object.is_in_group("Zombie"):
		zombies_left -= 1
		print(zombies_left)

func spawn_player():
	var player = Player.instance()
	add_child(player)
