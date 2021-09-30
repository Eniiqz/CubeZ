extends Node2D

onready var current_weapon
onready var weapons = []
onready var Player = get_parent()
onready var last_zombie_killed

export (PackedScene) var Bullet = preload("res://Bullet/Bullet.tscn")

func _ready():
	yield(GlobalSignal, "player_ready")
	GlobalSignal.connect("weapon_fired", self, "on_weapon_fired")
	GlobalSignal.connect("on_zombie_death", self, "on_zombie_death")
	weapons = get_children()
	for weapon in weapons:
		weapon.hide()
	if not current_weapon:
		switch_weapon($Pistol)
	set_process_input(true)
	

func switch_weapon(new_weapon):
	if current_weapon != null and current_weapon.is_reloading:
		current_weapon.cancel_reload()
	var previous_weapon = current_weapon
	if new_weapon != previous_weapon:
		if previous_weapon != null:
			previous_weapon.hide()
		current_weapon = new_weapon
		new_weapon.show()
		GlobalSignal.emit_signal("weapon_changed", previous_weapon, new_weapon)

func _create_bullet(direction):
	var NewBullet = Bullet.instance()
	NewBullet.connect("bullet_hit", self, "on_bullet_hit")
	var bullet_start_pos = current_weapon.WeaponEnd.get_global_position()
	Player.get_parent().add_child(NewBullet)
	NewBullet.set_global_position(bullet_start_pos)
	if direction:
		NewBullet.set_direction(((get_global_mouse_position() - bullet_start_pos) * direction).normalized())
	else:
		NewBullet.set_direction((get_global_mouse_position() - bullet_start_pos).normalized())
	NewBullet.set_weapon_fired_from(current_weapon)

func on_zombie_death(zombie):
	last_zombie_killed = zombie

func on_bullet_hit(bullet, object_hit):
	if object_hit is KinematicBody2D and object_hit.is_in_group("Zombie") and not object_hit.dead:
		object_hit.health -= current_weapon.damage
		if not current_weapon.is_shotgun:
			Player.set_points(Player.get_points() + 10)
		if last_zombie_killed == object_hit:
			Player.set_points(Player.get_points() + 70)
	if bullet.is_connected("bullet_hit", self, "on_bullet_hit"):
		bullet.disconnect("bullet_hit", self, "on_bullet_hit")
	bullet.queue_free()

func on_weapon_fired(weapon):
	if weapon == current_weapon:
		if weapon.is_shotgun:
			for shot in weapon.shots_in_burst:
				var random_spread = Vector2((rand_range(1, 6)), (rand_range(1, 6)))
				_create_bullet(random_spread)
		else:
			_create_bullet(false)
		if current_weapon.current_ammo_in_mag == 0 and current_weapon.auto_reload:
			current_weapon.reload()


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
					if not current_weapon.is_bursting and current_weapon.BurstCooldown.is_stopped():
						current_weapon.is_bursting = true
						for shot in current_weapon.shots_in_burst:
							current_weapon.shoot()
							yield(current_weapon.ShootCooldown, "timeout")
						current_weapon.BurstCooldown.start(current_weapon.burst_delay)
						current_weapon.is_bursting = false
		elif event.is_action_released("weapon_reload"):
			current_weapon.reload()
		elif event.is_action_released("weapon_slot_1"):
			switch_weapon(weapons[0])
		elif event.is_action_released("weapon_slot_2"):
			switch_weapon(weapons[1])
		elif event.is_action_pressed("weapon_slot_3"):
			switch_weapon(weapons[2])
		elif event.is_action_pressed("weapon_slot_4"):
			switch_weapon(weapons[3])
		elif event.is_action_pressed("weapon_slot_5"):
			switch_weapon(weapons[4])
