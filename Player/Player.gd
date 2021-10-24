extends KinematicBody2D
class_name Player

const scent_scene = preload("res://Player/Scent/Scent.tscn")

export (int) var move_speed = 150
export (float) var hit_cooldown = 0.5

export var can_move = false
export var can_shoot = false
export var can_look = false
export var can_sprint = false
export var can_regen = false

export (bool) var is_sprinting = false
export (bool) var is_shooting = false

export (float) var max_sprint_mult = 1.75
export (float)var sprint_mult = 1

export (int) var points = 500 setget set_points, get_points
export (int) var total_points = 500

export var health = 100
export var max_health = 100
export (bool) var invincible
var previous_health

onready var PlayerCamera = get_node("PlayerCamera")
onready var PlayerHitCooldown = get_node("HitCooldown")
onready var PlayerRegenCooldown = get_node("RegenCooldown")
onready var ScentCooldown = get_node("ScentCooldown")
onready var WeaponManager = get_node("WeaponManager")

onready var HUD = preload("res://User Interface/HUD.tscn")

onready var PlayerHUD

var scent_trail = []

func _ready():
	can_move = true
	can_shoot = true
	can_look = true
	can_sprint = true
	can_regen = true
	PlayerCamera.current = true
	PlayerHUD = HUD.instance()
	PlayerHUD.set_player(self)
	get_parent().add_child(PlayerHUD)
	GlobalSignal.connect("points_changed", self, "on_points_changed")
	#GlobalSignal.connect("wallbuy_activated", self, "wallbuy_activated")
	GlobalSignal.emit_signal("player_ready", self)
	ScentCooldown.connect("timeout", self, "add_scent")


var velocity = Vector2()

func add_scent():
	var scent = scent_scene.instance()
	scent.player = self
	scent.global_position = self.global_position
	get_parent().add_child(scent)
	scent_trail.push_front(scent)

func dead():
	GlobalSignal.emit_signal("on_player_death", self)
	ScentCooldown.disconnect("timeout", self, "add_scent")
	scent_trail.clear()
	queue_free()

func get_weapons():
	return WeaponManager.weapons

func set_health(new_health):
	previous_health = health
	health = max(0, new_health)
	on_health_update()
		
func get_health():
	return health

func on_health_update():
	if health != previous_health:
		GlobalSignal.emit_signal("health_changed", self, health)
	if health < previous_health:
		PlayerRegenCooldown.start()
	if health <= 0:
		dead()

func on_points_changed(player, previous_points, new_points):
	if player == self:
		if new_points > previous_points:
			var diff = new_points - previous_points
			total_points += diff
	

func set_points(new_points):
	var previous_points = points
	points = new_points
	GlobalSignal.emit_signal("points_changed", self, previous_points, points)
	
func get_points():
	return points

func _physics_process(delta):
	if health < max_health and can_regen and PlayerRegenCooldown.is_stopped():
		set_health(health + 25 * delta)
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
