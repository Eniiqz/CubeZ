extends Node2D

signal weapon_changed(new_weapon)
signal weapon_fired

onready var current_weapon
onready var weapons = []
onready var active_bullets = []
onready var Player = get_parent()
onready var PlayerHUD = Player.PlayerHUD

export (PackedScene) var Bullet = preload("res://Bullet/Bullet.tscn")

func _ready():
	weapons = get_children()
	for weapon in weapons:
		weapon.hide()
	if not current_weapon:
		switch_weapon($Pistol)
	set_process_input(true)



func switch_weapon(new_weapon):
	var previous_weapon = current_weapon
	if new_weapon != previous_weapon:
		if previous_weapon != null:
			previous_weapon.hide()
			if previous_weapon.is_connected("weapon_fired", self, "send_signal_up"):
				previous_weapon.disconnect("weapon_fired", self, "send_signal_up")
		current_weapon = new_weapon
		new_weapon.show()
		PlayerHUD.update_hud("Ammo", new_weapon.current_ammo_in_mag)
		PlayerHUD.update_hud("Reserve", new_weapon.current_ammo_reserve)
		if not new_weapon.is_connected("weapon_fired", self, "send_signal_up"):
			new_weapon.connect("weapon_fired", self, "send_signal_up")
		emit_signal("weapon_changed", new_weapon)
		
		
func _create_bullet():
	var NewBullet = Bullet.instance()
	active_bullets.append(NewBullet)
	NewBullet.connect("bullet_hit", self, "on_bullet_hit")
	var bullet_start_pos = current_weapon.WeaponEnd.get_global_position()
	Player.get_parent().add_child(NewBullet)
	NewBullet.position = bullet_start_pos
	NewBullet.set_direction((get_global_mouse_position() - bullet_start_pos).normalized())
	NewBullet.set_weapon_fired_from(current_weapon)

func on_bullet_hit(object_hit):
	if object_hit is KinematicBody2D and object_hit.is_in_group("Zombie"):
		object_hit.health -= current_weapon.damage

func send_signal_up():
	if current_weapon.current_ammo_in_mag > 0:
		_create_bullet()

func _process(delta):
	if current_weapon != null:
		var line_offset = Player.get_node("CollisionShape2D").shape.get_extents()
		current_weapon.WeaponLine.set_point_position(1, to_local(get_global_mouse_position()) - line_offset)
		if Input.is_action_pressed("weapon_shoot") and current_weapon.fire_mode == 1:
			current_weapon.shoot()

var can_burst = true
func _input(event: InputEvent):
	if current_weapon != null:
		if event.is_action_released("weapon_shoot"):
			match current_weapon.fire_mode:
				0:
					current_weapon.shoot()
				2:
					if can_burst and current_weapon.BurstCooldown.is_stopped():
						can_burst = false
						for shot in current_weapon.shots_in_burst:
							current_weapon.shoot()
							yield(current_weapon.ShootCooldown, "timeout")
						current_weapon.BurstCooldown.start(current_weapon.burst_delay)
						can_burst = true
		elif event.is_action_released("weapon_reload"):
			current_weapon.reload()
		elif event.is_action_released("weapon_slot_1"):
			switch_weapon(weapons[0])
		elif event.is_action_released("weapon_slot_2"):
			switch_weapon(weapons[1])
		elif event.is_action_pressed("weapon_slot_3"):
			switch_weapon(weapons[2])
