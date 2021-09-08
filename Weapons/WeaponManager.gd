extends Node2D

signal weapon_changed(new_weapon)
signal weapon_fired(weaponed_fired)

onready var current_weapon
onready var weapons = []

onready var PlayerRaycast = get_parent().get_node("RayCast2D")

func _ready():
	print("weapon manager ready")
	weapons = get_children()
	for weapon in weapons:
		weapon.hide()
	if not current_weapon:
		switch_weapon($Pistol)
		weapons[0] = $Pistol
		weapons[1] = $SMG
	current_weapon.show()
	set_process_input(true)

func reload():
	pass


func switch_weapon(weapon):
	if weapon != current_weapon and current_weapon != null:
		current_weapon.disconnect("weapon_fired", self, "send_signal_up") 
		current_weapon.hide()
		weapon.show()
		emit_signal("weapon_changed", weapon)
		current_weapon = weapon
	elif current_weapon == null:
		current_weapon = weapon
		current_weapon.show()
		emit_signal("weapon_changed", current_weapon)
	if not current_weapon.is_connected("weapon_fired", self, "send_signal_up"):
		current_weapon.connect("weapon_fired", self, "send_signal_up")
		
func _shoot():
		current_weapon.shoot()

func send_signal_up():
	print("weapon actually fired")

func _process(delta):
	if current_weapon != null:
		current_weapon.WeaponLine.set_point_position(1, to_local(get_global_mouse_position()) - Vector2(20, 20))
		if current_weapon.fire_mode == 1 and Input.is_action_pressed("weapon_shoot"):
			_shoot()
		elif current_weapon.fire_mode == 2 and Input.is_action_pressed("weapon_shoot"):
			#handle burst
			pass

func _input(event: InputEvent):
	if current_weapon != null:
		if current_weapon.fire_mode == 0 and event.is_action_released("weapon_shoot"):
			_shoot()
		elif event.is_action_released("weapon_reload"):
			current_weapon.reload()
		elif event.is_action_released("weapon_slot_1"):
			switch_weapon(weapons[0])
