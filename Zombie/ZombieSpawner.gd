extends Node2D

onready var SpawnTimer = get_node("SpawnTimer")
onready var World = get_parent()
export (int) onready var spawn_time

const Zombie = preload("res://Zombie/Zombie.tscn")

func _ready():
	SpawnTimer.start(float(spawn_time))
	SpawnTimer.connect("timeout", self, "spawn_zombie")

func spawn_zombie():
	if World.zombies_spawned_in_round < World.zombies_in_round and World.active_zombies < 24 and World.RoundEnd.is_stopped():
		World.zombies_spawned_in_round += 1
		World.active_zombies += 1
		var new_zombie = Zombie.instance()
		new_zombie.global_position = global_position
		World.add_child(new_zombie)
		print("spawned")
