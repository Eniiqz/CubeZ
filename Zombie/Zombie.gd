extends KinematicBody2D

export onready var TargetedPlayer = null

onready var PathfindRaycast = get_node("PathfindRaycast")
onready var PathfindTimer = get_node("PathfindTimer")
onready var NavAgent = get_node("NavAgent")

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
	#PathfindTimer.connect("timeout", self, "handle_navigation")
	NavAgent.connect("velocity_computed", self, "on_velocity_computed")
	print(self, "loaded")
	PathfindTimer.start()
	NavAgent.max_speed = speed
	

func dead():
	GlobalSignal.emit_signal("on_zombie_death", self)
	queue_free()

func set_health(new_health):
	previous_health = health
	health = max(0, new_health)
	on_health_update()
		
func get_health():
	return health

func set_target_location(target: Vector2):
	NavAgent.set_target_location(target)

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
	if TargetedPlayer != null and TargetedPlayer and TargetedPlayer.is_in_group("Player"):
		#set_target_location(TargetedPlayer.global_position)
		direction = global_position.direction_to(NavAgent.get_next_location())
		#$Line2D.global_position = Vector2.ZERO
		#$Line2D.points = NavAgent.get_nav_path()
		#print(NavAgent.get_nav_path())
		var velocity = direction * speed
		NavAgent.set_velocity(velocity)
		#velocity = move_and_slide(velocity)
		PathfindRaycast.cast_to = TargetedPlayer.global_position
		PathfindRaycast.force_raycast_update()
		if !PathfindRaycast.is_colliding():
			look_at(TargetedPlayer.get_global_position())
	else:
		TargetedPlayer = search_for_player()

func on_velocity_computed(computed_velocity):
	var velocity = computed_velocity
	velocity = move_and_slide(velocity)
	
	for i in get_slide_count():
			var collision = get_slide_collision(i)
			var collider = collision.collider
			if collider.is_in_group("Player") and collider.PlayerHitCooldown.is_stopped() and not collider.invincible:
				collider.PlayerHitCooldown.start(collider.hit_cooldown)
				collider.set_health(collider.health - damage)
			elif collider.is_in_group("Zombie"):
				pass
			
				#move_from_zombie(collider)

func _on_PathfindTimer_timeout():
	if TargetedPlayer != null:
		set_target_location(TargetedPlayer.global_position)
		
