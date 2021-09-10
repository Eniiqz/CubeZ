extends Node2D

const Player = preload("res://Player/Player.tscn")
const Zombie = preload("res://Zombie/Zombie.tscn")

func _ready():
	spawn_player()


func spawn_player():
	var player = Player.instance()
	add_child(player)
