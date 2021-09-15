extends Node2D
class_name ZombieSpawner

onready var SpawnTimer = get_node("SpawnTimer")

export (int) onready var spawn_time

const Zombie = preload("res://Zombie/Zombie.tscn")

func _ready():
	SpawnTimer.connect("timeout", self, "spawn_zombie")

func spawn_zombie():
	var new_zombie = Zombie.instance()
	
