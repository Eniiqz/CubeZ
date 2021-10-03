extends MarginContainer

export (ButtonGroup) var group

var selected_level
onready var levels = []
func _ready():
	levels = group.get_buttons()
	for lvl in levels:
		lvl.connect("pressed", self, "on_button_pressed")
	get_node("CenterContainer/0").grab_focus()

func on_button_pressed():
	var button_pressed = group.get_pressed_button()
	selected_level = button_pressed.name
	get_tree().change_scene("res://World/World.tscn")
	#var level_name = "Level" + selected_level
	#var level_string = "res://World/" + level_name + "/" + level_name + ".tscn"
	#get_tree().change_scene(level_string)
