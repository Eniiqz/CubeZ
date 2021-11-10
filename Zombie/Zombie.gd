extends KinematicBody2D

export onready var TargetedPlayer = null

onready var PathfindRaycast = get_node("PathfindRaycast")
onready var PathfindTimer = get_node("PathfindTimer")

var velocity = Vector2()
var direction = Vector2()
export var can_move = false
export var can_look_at_player = false

export var damage = 50
export (int) var speed

export var max_health = 50
export var health  = 50 setget set_health, get_health
var previous_health = health
var dead = false

var path: Array = []
var navigation

func _ready():
	GlobalSignal.connect("on_player_death", self, "on_player_death")
	PathfindTimer.connect("timeout", self, "handle_navigation")

func dead():
	GlobalSignal.emit_signal("on_zombie_death", self)
	queue_free()

func set_health(new_health):
	previous_health = health
	health = max(0, new_health)
	on_health_update()
		
func get_health():
	return health

func set_navigation(new_nav):
	navigation = new_nav

func handle_navigation():
	if TargetedPlayer != null:
		PathfindRaycast.cast_to = TargetedPlayer.global_position
		PathfindRaycast.force_raycast_update()
		if PathfindRaycast.is_colliding():
			var collider = PathfindRaycast.get_collider()
			if collider != TargetedPlayer:
				generate_path()
				navigate()
			else:

				direction = global_position.direction_to(PathfindRaycast.cast_to)


func on_player_death(player):
	if player == TargetedPlayer:
		TargetedPlayer = null

func on_health_update():
	if health != previous_health:
		GlobalSignal.emit_signal("health_changed", self, health)
	if health <= 0 and not dead:
		dead = true
		dead()

func search_for_player():
	var player_distances = {}
	if get_tree().get_nodes_in_group("Player").empty():
		return null
	for Player in get_tree().get_nodes_in_group("Player"):
		player_distances[Player] = Player.get_global_position().distance_to(self.get_global_position())
	var min_value = player_distances.values().min()
	for Player in player_distances:
		var value = player_distances[Player]
		if value == min_value:
			return Player

func move_from_zombie(zombie):
	PathfindRaycast.cast_to = (zombie.global_position)
	var move_dir = -(global_position.direction_to(PathfindRaycast.cast_to))
	direction = move_dir
	
func generate_path():
	if navigation != null and TargetedPlayer != null:
		path = navigation.get_simple_path(global_position, TargetedPlayer.global_position, false)

func navigate():
	if path.size() > 0:
		direction = global_position.direction_to(path[1])
		
		if global_position.distance_to(path[0]) < 2:
			path.pop_front()

func _physics_process(delta):
	if TargetedPlayer is KinematicBody2D and TargetedPlayer.is_in_group("Player"):
		var velocity = direction * speed
		velocity = move_and_slide(velocity)
		PathfindRaycast.cast_to = TargetedPlayer.global_position
		PathfindRaycast.force_raycast_update()
		if !PathfindRaycast.is_colliding():
			look_at(TargetedPlayer.get_global_position())
		for i in get_slide_count():
			var collision = get_slide_collision(i)
			var collider = collision.collider
			if collider.is_in_group("Player") and collider.PlayerHitCooldown.is_stopped() and not collider.invincible:
				collider.PlayerHitCooldown.start(collider.hit_cooldown)
				collider.set_health(collider.health - damage)
			elif collider.is_in_group("Zombie"):
				move_from_zombie(collider)
	else:
		TargetedPlayer = search_for_player()
