extends Node2D

signal weapon_changed(new_weapon)
signal weapon_fired(weaponed_fired)

onready var current_weapon
onready var weapons = []

onready var Player = get_parent()
onready var PlayerRaycast = Player.get_node("RayCast2D")
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
		
func _shoot():
		current_weapon.shoot()
		if current_weapon.current_ammo_in_mag > 0:
			_create_bullet()

func _create_bullet():
	var NewBullet = Bullet.instance()
	NewBullet.connect("bullet_hit", self, "send_signal_up")
	var bullet_start_pos = current_weapon.WeaponEnd.get_global_position()
	var bullet_rot_deg = Player.get_rotation_degrees()
	NewBullet.position = bullet_start_pos
	NewBullet.set_rotation_degrees(bullet_rot_deg)
	Player.owner.add_child(NewBullet)
	NewBullet.set_weapon_fired_from(current_weapon)

func send_signal_up(object_hit):
	print(object_hit)
	if object_hit is KinematicBody2D and object_hit.is_in_group("Zombie"):
		object_hit.health -= current_weapon.damage
	# TODO: Switch to using actual Bullet, raycasting is kinda whack i think
	#PlayerRaycast.cast_to = Vector2(current_weapon.max_range, 0)
	#PlayerRaycast.enabled = true
	#PlayerRaycast.force_raycast_update()
	#if PlayerRaycast.is_colliding():
		#var collider = PlayerRaycast.get_collider()
		#if collider is KinematicBody2D and collider.is_in_group("Zombie"):
		#	collider.health -= current_weapon.damage
	#PlayerRaycast.enabled = false

func _process(delta):
	if current_weapon != null:
		current_weapon.WeaponLine.set_point_position(1, to_local(get_global_mouse_position()) - Vector2(20, 20))
		if Input.is_action_pressed("weapon_shoot"):
			match current_weapon.fire_mode:
				1:
					_shoot()
				2:
					pass
					# Handle burst fire

func _input(event: InputEvent):
	if current_weapon != null:
		if current_weapon.fire_mode == 0 and event.is_action_released("weapon_shoot"):
			_shoot()
		elif event.is_action_released("weapon_reload"):
			current_weapon.reload()
		elif event.is_action_released("weapon_slot_1"):
			switch_weapon(weapons[0])
		elif event.is_action_released("weapon_slot_2"):
			switch_weapon(weapons[1])
