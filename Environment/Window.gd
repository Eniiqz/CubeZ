extends Area2D

export (int) var max_boards = 6
export (int) var current_boards = max_boards

onready var BoardTimer = get_node("BoardTimer")
onready var BoardRepairTimer = get_node("BoardRepairTimer")
onready var active_zombies = []

func _ready():
	pass
	

func update_boards(amount):
	current_boards = clamp(0, current_boards + amount, max_boards)
	

func _on_Window_body_entered(body):
	if body.is_in_group("Zombie") and BoardTimer.is_stopped():
		if not active_zombies.has(body):
			active_zombies.append(body)
			BoardTimer.start()
	elif body.is_in_group("Player"):
		GlobalSignal.emit_signal("barrier_activated", true, body, self)



func _on_Window_body_exited(body):
	if body.is_in_group("Zombie") and active_zombies.has(body):
		active_zombies.erase(body)
	elif body.is_in_group("Player"):
		GlobalSignal.emit_signal("barrier_activated", false, body, self)


func _on_BoardTimer_timeout():
	if not active_zombies.empty() and current_boards > 0:
		self.update_boards(-1)
		GlobalSignal.emit_signal("barrier_updated", self)
		if current_boards == 0:
			$Board.visible = false
			$Board.set_collision_mask_bit(1, false)
			active_zombies.clear()
			return
		print(current_boards)
		BoardTimer.start()

func _on_BoardRepairTimer_timeout():
	if current_boards + 1 <= max_boards:
		self.update_boards(1)
		GlobalSignal.emit_signal("barrier_updated", self)
