extends Node



signal weapon_fired(weapon)
signal weapon_reloaded(weapon)
signal weapon_out_of_ammo(weapon)
signal weapon_changed(previous_weapon, new_weapon)
signal weapon_ammo_changed(weapon, new_ammo, new_reserve)

signal health_changed(object, new_health)
