extends CanvasLayer

onready var Ammo = get_node("Ammo")
onready var ReserveAmmo = get_node("Reserve")
onready var Weapon = get_node("Weapon")
onready var Health = get_node("Health")
onready var RoundCounter = get_node("RoundCounter")
onready var Interaction = get_node("Interaction")
onready var Powerup = get_node("Powerup")

var Player
var player_in_wallbuy_zone
var player_in_barrier
var CurrentWeapon

func _ready():
	GlobalSignal.connect("weapon_ammo_changed", self, "on_weapon_ammo_changed")
	GlobalSignal.connect("weapon_changed", self, "on_weapon_changed")
	GlobalSignal.connect("weapon_reloaded", self, "on_weapon_reloaded")
	GlobalSignal.connect("health_changed", self, "on_health_changed")
	GlobalSignal.connect("round_ended", self, "on_round_end")
	GlobalSignal.connect("wallbuy_activated", self, "on_wallbuy_event")
	GlobalSignal.connect("barrier_activated", self, "on_barrier_activated_event")
	GlobalSignal.connect("barrier_updated", self, "on_barrier_updated_event")

func set_player(new_player):
	yield(self, "ready")
	if Player != new_player:
		Player = new_player
		Health.set_value(float(Player.health))

func on_round_end(next_round):
	update_hud("RoundCounter", next_round)

func on_weapon_reloaded(weapon):
	if weapon == CurrentWeapon:
		update_hud("Ammo", weapon.current_ammo_in_mag)
		update_hud("Reserve", weapon.current_ammo_reserve)

func on_weapon_changed(previous_weapon, new_weapon):
	CurrentWeapon = new_weapon
	Weapon.text = CurrentWeapon.name
	update_hud("Ammo", new_weapon.current_ammo_in_mag)
	update_hud("Reserve", new_weapon.current_ammo_reserve)

func on_weapon_ammo_changed(weapon, new_ammo, new_reserve):
	if weapon == CurrentWeapon:
		update_hud("Ammo", new_ammo)
		update_hud("Reserve", new_reserve)

func on_health_changed(object, new_health):
	if object == Player:
		Health.set_value(float(new_health))

func on_wallbuy_event(entering, player, wallbuy):
	if player == Player:
		Interaction.visible = entering
		if entering:
			var formatted_string = "Hold F for %s // [Cost: $%s]"
			var actual_string = formatted_string % [wallbuy.weapon, WeaponData.get_cost(wallbuy.weapon)] # TODO: add text per desired user input
			Interaction.text = actual_string
		else:
			Interaction.text = ""
			

func on_barrier_activated_event(entering, player, barrier):
	var current_boards = barrier.current_boards
	var max_boards = barrier.max_boards
	
	
	print(barrier, barrier.current_boards, barrier.max_boards)
	#current_boards = barrier.current_boards
	#max_boards = barrier.max_boards
	
	if player == Player:
		Interaction.visible = entering
		player_in_barrier = entering
		if entering:
			var formatted_string = "Hold F to repair ({current} / {max}).".format({"current": current_boards, "max": max_boards})
			Interaction.text = formatted_string
		else:
			Interaction.text = ""

func on_barrier_updated_event(barrier):
	var current_boards = barrier.current_boards
	var max_boards = barrier.max_boards
	
	if Interaction.visible:
		var formatted_string = "Hold F to repair ({current} / {max}).".format({"current": current_boards, "max": max_boards})
		Interaction.text = formatted_string

func on_powerup_touched(powerup):
	if powerup.type == "Instakill":
		Powerup.visible = true
		Powerup.text = "Instakill: 30"
	
func _input(event):
	if player_in_wallbuy_zone and event.is_action_pressed("action_use"):
		# buy weapon
		pass
	if player_in_barrier and event.is_action_pressed("action_use"):
		pass

func update_hud(node_name: String, new_value):
	var node = get_node_or_null(node_name)
	if node != null:
		node.text = String(new_value)
