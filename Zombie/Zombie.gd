extends KinematicBody2D

export onready var TargetedPlayer = null
export var can_move = false
export var can_look_at_player = false
export var type = "Enemy"

export var max_health = 100
export var health  = 100 setget set_health, get_health
var previous_health = health

onready var ZombieArea = get_node("Area2D")


signal on_damage
signal on_health_given
signal on_death

func _ready():
	pass

func damage_taken():
	emit_signal("on_damage")
	print(health, " ", previous_health)

func health_given():
	emit_signal("on_health_given")
	pass

func dead():
	emit_signal("on_death")
	queue_free()

func set_health(new_health):
	previous_health = health
	if new_health < 0:
		new_health = 0
	health = new_health
	on_health_update()
		
func get_health():
	return health

func on_health_update():
	if health != previous_health and health < previous_health:
		damage_taken()
	if health != previous_health and health > previous_health:
		health_given()
	if health <= 0:
		dead()

func _on_Area2D_body_entered(body: Node) -> void:
	if body is KinematicBody2D and body.name == "Player":
		TargetedPlayer = body
		

func _on_Area2D_body_exited(body: Node) -> void:
	if TargetedPlayer == body:
		TargetedPlayer = null

func _physics_process(delta):
	if TargetedPlayer != null:
		look_at(TargetedPlayer.position)
