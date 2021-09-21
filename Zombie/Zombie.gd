extends KinematicBody2D

export onready var TargetedPlayer = null
onready var PathfindTimer = get_node("PathfindTimer")

var velocity = Vector2()
export var can_move = false
export var can_look_at_player = false

export var damage = 50
export (int) var speed

export var max_health = 50
export var health  = 50 setget set_health, get_health
var previous_health = health
var dead = false

var path = []
var navigation

func _ready():
	GlobalSignal.connect("on_player_death", self, "on_player_death")
	PathfindTimer.connect("timeout", self, "get_path_to_target")

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

func get_path_to_target():
	if TargetedPlayer is KinematicBody2D and TargetedPlayer.is_in_group("Player"):
		path = navigation.get_simple_path(global_position, TargetedPlayer.global_position, false)

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
	
func _physics_process(delta):
	if TargetedPlayer is KinematicBody2D and TargetedPlayer.is_in_group("Player"):
		if path.size() > 0:
			var distance_to_next_point = global_position.distance_to(path[0])
			if distance_to_next_point < 16:
				path.remove(0)
			else:
				var direction = global_position.direction_to(path[0])
				move_and_slide(direction * speed)


		
		#var direction = (TargetedPlayer.get_global_position() - self.get_global_position()).normalized()
		#move_and_slide(direction * speed)
		look_at(TargetedPlayer.get_global_position())
		for i in get_slide_count():
			var collision = get_slide_collision(i)
			var collider = collision.collider
			if collider.is_in_group("Player") and collider.PlayerHitCooldown.is_stopped() and not collider.invincible:
				collider.PlayerHitCooldown.start(collider.hit_cooldown)
				collider.set_health(collider.health - damage)
	else:
		TargetedPlayer = search_for_player()
