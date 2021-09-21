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

var navigation_path = PoolVector2Array()
var navigation = null setget set_navigation

func _ready():
	GlobalSignal.connect("on_player_death", self, "on_player_death")
	PathfindTimer.connect("timeout", self, "get_target_path")

func dead():
	GlobalSignal.emit_signal("on_zombie_death", self)
	queue_free()
	
func set_navigation(new_navigation):
	navigation = new_navigation

func get_target_path():
	if TargetedPlayer is KinematicBody2D and TargetedPlayer.is_in_group("Player"):
		print("updating path")
		navigation_path = navigation.get_simple_path(global_position, TargetedPlayer.get_global_position(), false)
		print(navigation_path)
		
func set_health(new_health):
	previous_health = health
	health = max(0, new_health)
	on_health_update()
		
func get_health():
	return health

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

func move_to_target():
	print(global_position.distance_to(navigation_path[0]))
	if global_position.distance_to(navigation_path[0]) < 32:
		navigation_path.remove(0)
	else:
		var direction = global_position.direction_to(navigation_path[0])
		velocity = direction * speed
		velocity = move_and_slide(velocity)

func _physics_process(delta):
	if TargetedPlayer is KinematicBody2D and TargetedPlayer.is_in_group("Player"):
		#var direction = (TargetedPlayer.get_global_position() - self.get_global_position()).normalized()
		if navigation_path.size() > 0:
			move_to_target()
		
		
		
		
		#look_at(TargetedPlayer.get_global_position())
		for i in get_slide_count():
			var collision = get_slide_collision(i)
			var collider = collision.collider
			if collider.is_in_group("Player") and collider.PlayerHitCooldown.is_stopped() and not collider.invincible:
				collider.PlayerHitCooldown.start(collider.hit_cooldown)
				collider.set_health(collider.health - damage)
	else:
		TargetedPlayer = search_for_player()
