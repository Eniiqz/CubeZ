extends Node2D

signal weapon_changed(new_weapon)
signal weapon_fired

onready var current_weapon
onready var weapons = []

onready var Player = get_parent()
export (PackedScene) var Bullet = preload("res://Bullet/Bullet.tscn")

func _ready():
	weapons = get_children()
	for weapon in weapons:
		weapon.hide()
	if not current_weapon:
		switch_weapon($Pistol)
	current_weapon.show()
	set_process_input(true)

func switch_weapon(weapon):
	if weapon != current_weapon and current_weapon != null:
		current_weapon.disconnect("weapon_fired", self, "send_signal_up") 
		current_weapon.hide()
		current_weapon.is_equipped = false
		weapon.show()
		emit_signal("weapon_changed", weapon)
		current_weapon = weapon
		current_weapon.is_equipped = true
	elif current_weapon == null:
		current_weapon = weapon
		current_weapon.is_equipped = true
		current_weapon.show()
		emit_signal("weapon_changed", current_weapon)
	if not current_weapon.is_connected("weapon_fired", self, "send_signal_up"):
		print(current_weapon.name)
		current_weapon.connect("weapon_fired", self, "send_signal_up")
		

func _create_bullet():
	var NewBullet = Bullet.instance()
	NewBullet.connect("bullet_hit", self, "on_bullet_hit")
	var bullet_start_pos = current_weapon.WeaponEnd.get_global_position()
	Player.owner.add_child(NewBullet)
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

func _input(event: InputEvent):
	if current_weapon != null:
		if event.is_action_released("weapon_shoot"):
			match current_weapon.fire_mode:
				0:
					current_weapon.shoot()
				2:
					if current_weapon.BurstCooldown.is_stopped() == true:
						var shot_counter = 0
						for shot in current_weapon.shots_in_burst:
							shot_counter += 1
							current_weapon.shoot()
							yield(current_weapon.ShootCooldown, "timeout")
						current_weapon.BurstCooldown.start(current_weapon.burst_delay)
						yield(current_weapon.BurstCooldown, "timeout")
						print(shot_counter)
						print(current_weapon.times_called)
						current_weapon.times_called = 0
		elif event.is_action_released("weapon_reload"):
			current_weapon.reload()
		elif event.is_action_released("weapon_slot_1"):
			switch_weapon(weapons[0])
		elif event.is_action_released("weapon_slot_2"):
			switch_weapon(weapons[1])
		elif event.is_action_pressed("weapon_slot_3"):
			switch_weapon(weapons[2])
