extends KinematicBody2D

export onready var TargetedPlayer = null
export var can_move = false
export var can_look_at_player = false

export var damage = 25

export var max_health = 100
export var health  = 100 setget set_health, get_health
var previous_health = health

onready var ZombieArea = get_node("Area2D")

func _ready():
	pass

func dead():
	GlobalSignal.emit_signal("on_death")
	queue_free()

func set_health(new_health):
	previous_health = health
	health = max(0, new_health)
	on_health_update()
		
func get_health():
	return health

func on_health_update():
	if health != previous_health:
		GlobalSignal.emit_signal("health_changed", self, health)
	if health <= 0:
		dead()

func _on_Area2D_body_entered(body: Node) -> void:
	if body is KinematicBody2D and body.is_in_group("Player"):
		TargetedPlayer = body
	elif body is Node2D and body.is_in_group("Bullet"):
		body.queue_free()
		

func _on_Area2D_body_exited(body: Node) -> void:
	if TargetedPlayer == body:
		TargetedPlayer = null

func _physics_process(delta):
	if TargetedPlayer != null:
		look_at(TargetedPlayer.position)
		var direction = (TargetedPlayer.get_global_position() - self.get_global_position()).normalized()
