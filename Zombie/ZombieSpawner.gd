extends Node2D
class_name ZombieSpawner

const Zombie = preload("res://Zombie/Zombie.tscn")

func _ready():
	pass

func spawn_zombie():
	var new_zombie = Zombie.instance()
	
