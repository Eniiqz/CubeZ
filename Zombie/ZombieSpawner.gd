extends Node2D

onready var SpawnTimer = get_node("SpawnTimer")

export (int) onready var spawn_time

const Zombie = preload("res://Zombie/Zombie.tscn")

func _ready():
	SpawnTimer.start(float(spawn_time))
	SpawnTimer.connect("timeout", self, "spawn_zombie")

func spawn_zombie():
	get_parent().zombies_left += 1
	var new_zombie = Zombie.instance()
	new_zombie.global_position = global_position
	get_parent().add_child(new_zombie)
	print("spawned")
