extends Area2D

export var max_boards: int = 6
export var current_boards: int = max_boards

onready var BoardTimer = get_node("BoardTimer")
onready var active_zombies = []

func _ready():
	pass
	
	

func _on_Window_body_entered(body):
	if body.is_in_group("Zombie") and BoardTimer.is_stopped():
		if not active_zombies.has(body):
			active_zombies.append(body)
			BoardTimer.start()



func _on_Window_body_exited(body):
	if body.is_in_group("Zombie") and active_zombies.has(body):
		active_zombies.erase(body)


func _on_BoardTimer_timeout():
	if not active_zombies.empty() and current_boards > 0:
		current_boards = max(0, current_boards - 1)
		if current_boards == 0:
			$Board.visible = false
			$Board.set_collision_mask_bit(1, false)
			active_zombies.clear()
			return
		BoardTimer.start()
