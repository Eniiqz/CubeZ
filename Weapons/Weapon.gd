extends Node2D
class_name Weapon


onready var ShootCooldown = get_node("ShootCooldown")
onready var BurstCooldown = get_node("BurstCooldown")
onready var ReloadTimer = get_node("Reload")
onready var WeaponLine = get_node("Line2D")
onready var WeaponEnd = get_node("WeaponEnd")

enum FIRE_MODE {SEMI, AUTO, BURST}

export (int) var default_ammo_in_mag
export (int) var current_ammo_in_mag
export (int) var default_ammo_reserve
export (int) var current_ammo_reserve


export (int) onready var fire_rate
export (FIRE_MODE) onready var fire_mode
export (int) onready var damage
export (int) onready var max_range
export (float) onready var reload_time
export (int) onready var bullet_velocity

export (bool) var can_shoot = false
export (bool) var auto_reload = true


export (bool) var is_shotgun = false
export (bool) var is_equipped = false
export (bool) var is_reloading = false
export (bool) var is_bursting = false

export (int) var shots_in_burst
export (float) var shot_delay
export (float) var burst_delay
export (bool) var burst_finished = true

func _ready():
	can_shoot = true
	current_ammo_in_mag = default_ammo_in_mag
	current_ammo_reserve = default_ammo_reserve
	shot_delay = (60 / float(fire_rate))
	if fire_mode == 2:
		burst_delay = shot_delay * shots_in_burst
	WeaponLine.set_point_position(0, WeaponEnd.position)
	ReloadTimer.connect("timeout", self, "_finish_reload")
	
func cancel_reload():
	ReloadTimer.stop()
	is_reloading = false
	
func _finish_reload():
	var rounds_needed = default_ammo_in_mag - current_ammo_in_mag
	var original_reserve = current_ammo_reserve
	if rounds_needed <= current_ammo_reserve:
		current_ammo_in_mag += rounds_needed
		current_ammo_reserve -= rounds_needed
	elif current_ammo_reserve == 0:
		GlobalSignal.emit_signal("weapon_out_of_ammo", self)
	else:
		current_ammo_in_mag += current_ammo_reserve
		current_ammo_reserve = 0
	if current_ammo_reserve != original_reserve:
		GlobalSignal.emit_signal("weapon_ammo_changed", self, current_ammo_in_mag, current_ammo_reserve)
		GlobalSignal.emit_signal("weapon_reloaded", self)
	is_reloading = false
	if fire_mode == 2:
		is_bursting = false

func _shotgun_reload():
	pass

func reload():
	if current_ammo_in_mag < default_ammo_in_mag:
		is_reloading = true
		ReloadTimer.start(reload_time)

func shoot():
	if is_reloading and current_ammo_in_mag > 0:
		cancel_reload()
	if can_shoot and not is_reloading and current_ammo_in_mag > 0 and ShootCooldown.is_stopped():
		ShootCooldown.start(shot_delay)
		current_ammo_in_mag -= 1
		GlobalSignal.emit_signal("weapon_fired", self)
		GlobalSignal.emit_signal("weapon_ammo_changed", self, current_ammo_in_mag, current_ammo_reserve)
