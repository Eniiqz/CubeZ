extends KinematicBody2D

export onready var TargetedPlayer = null

export var can_move = false
export var can_look_at_player = false

export var damage = 50
export (int) var speed

export var max_health = 50
export var health  = 50 setget set_health, get_health
var previous_health = health

func _ready():
	GlobalSignal.connect("on_player_death", self, "on_player_death")

func dead():
	GlobalSignal.emit_signal("on_zombie_death", self)
	queue_free()

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
	if health <= 0:
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
	if TargetedPlayer is KinematicBody2D:
		var direction = (TargetedPlayer.get_global_position() - self.get_global_position()).normalized()
		move_and_slide(speed * direction)
		look_at(TargetedPlayer.get_global_position())
		for i in get_slide_count():
			var collision = get_slide_collision(i)
			var collider = collision.collider
			if collider.is_in_group("Player") and collider.PlayerHitCooldown.is_stopped() and not collider.invincible:
				collider.PlayerHitCooldown.start(collider.hit_cooldown)
				collider.set_health(collider.health - damage)
	else:
		TargetedPlayer = search_for_player()
