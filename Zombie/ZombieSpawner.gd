extends Node2D
class_name ZombieSpawner

onready var SpawnTimer = get_node("SpawnTimer")

export (int) onready var spawn_time

const Zombie = preload("res://Zombie/Zombie.tscn")

func _ready():
	SpawnTimer.start(float(spawn_time))
	SpawnTimer.connect("timeout", self, "spawn_zombie")

func spawn_zombie():
	print("zombie spawned", spawn_time)
	var new_zombie = Zombie.instance()
	get_parent().add_child(new_zombie)
