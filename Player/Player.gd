extends KinematicBody2D
class_name Player

export var move_speed = 150

export var can_move = false
export var can_shoot = false
export var can_look = false
export var can_sprint = false

export var is_sprinting = false
export var is_shooting = false

export var max_sprint_mult = 1.75
export var sprint_mult = 1

export var health = 100
export var max_health = 100


onready var PlayerRaycast = get_node("RayCast2D")
onready var PlayerArea = get_node("Area2D")

signal on_damage
signal on_health_given
signal on_death


func _ready():
	can_move = true
	can_shoot = true
	can_look = true
	can_sprint = true

var velocity = Vector2()


func _physics_process(delta):
	velocity = Vector2()
	if can_move:
		if Input.is_action_pressed("move_right"):
			velocity.x += 1
		if Input.is_action_pressed("move_left"):
			velocity.x -= 1
		if Input.is_action_pressed("move_up"):
			velocity.y -= 1
		if Input.is_action_pressed("move_down"):
			velocity.y += 1
		if Input.is_action_pressed("move_sprint"):
			if can_sprint and not is_sprinting:
				sprint_mult = max_sprint_mult
				is_sprinting = true
		else:
			sprint_mult = 1
			is_sprinting = false
		if velocity != Vector2.ZERO:
			velocity = move_and_slide(velocity.normalized() * move_speed * sprint_mult)
	if can_look:
		look_at(get_global_mouse_position())
