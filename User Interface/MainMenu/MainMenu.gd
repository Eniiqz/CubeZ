extends MarginContainer

func _ready():
	$CenterContainer/VBoxContainer/CenterContainer2/VBoxContainer/Start.grab_focus()

func _on_Start_pressed():
	get_tree().change_scene("res://World/World.tscn")


func _on_Options_pressed():
	pass # Replace with function body.


func _on_Quit_pressed():
	get_tree().quit()
