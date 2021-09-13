extends KinematicBody2D
class_name Player

export var move_speed = 150
export var hit_cooldown = 0.5

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
var previous_health

onready var PlayerCamera = get_node("PlayerCamera")
onready var PlayerHitCooldown = get_node("HitCooldown")
onready var WeaponManager = get_node("WeaponManager")
onready var HUD = preload("res://User Interface/HUD.tscn")

onready var PlayerHUD

func _ready():
	can_move = true
	can_shoot = true
	can_look = true
	can_sprint = true
	PlayerCamera.current = true
	PlayerHUD = HUD.instance()
	PlayerHUD.set_player(self)
	PlayerHUD.make_connections()
	get_parent().add_child(PlayerHUD)

var velocity = Vector2()


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
	health = max(0, new_health)
	GlobalSignal.emit_signal("health_changed", self, new_health)
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

func on_weapon_fired(weapon):
	emit_signal("on_weapon_fired", weapon)
	
func on_weapon_changed(new_weapon):
	emit_signal("on_weapon_changed", new_weapon)
	

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
		for i in get_slide_count():
			var collision = get_slide_collision(i)
			var collider = collision.collider
			if collider.is_in_group("Zombie") and PlayerHitCooldown.is_stopped():
				PlayerHitCooldown.start(hit_cooldown)
				set_health(health - collider.damage)
	if can_look:
		look_at(get_global_mouse_position())
