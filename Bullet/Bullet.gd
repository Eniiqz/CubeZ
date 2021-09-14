extends Node2D
class_name Bullet

var weapon_fired_from setget set_weapon_fired_from
var direction = Vector2() setget set_direction

signal bullet_hit(bullet, object_hit)

func set_weapon_fired_from(current_weapon):
	weapon_fired_from = current_weapon

func set_direction(new_direction: Vector2):
	direction = new_direction
	rotation += direction.angle()

func _physics_process(delta: float) -> void:
	if weapon_fired_from != null and direction != Vector2.ZERO:
		var distance_from_weapon = global_position.distance_to(weapon_fired_from.WeaponEnd.global_position)
		# TODO: BULLET IS NOT LINED UP WITH LINE AND MOUSE CURSOR, COULD BE PART OF A LARGER ISSUE!!
		var velocity = direction * weapon_fired_from.bullet_velocity
		global_position += velocity * delta
		if distance_from_weapon > weapon_fired_from.max_range:
			queue_free()


func _on_Bullet_body_entered(body: Node) -> void:
	if body is KinematicBody2D and body.is_in_group("Zombie"):
		emit_signal("bullet_hit", self, body)
	print(body)
	queue_free()
	
