extends Node

signal weapon_fired(weapon)
signal weapon_reloaded(weapon)
signal weapon_out_of_ammo(weapon)
signal weapon_changed(previous_weapon, new_weapon)
signal weapon_ammo_changed(weapon, new_ammo, new_reserve)
signal player_ready(player)
signal round_ended(next_round)
signal health_changed(object, new_health)
signal on_player_death(player)
signal on_zombie_death(zombie)
signal on_zombie_spawned(zombie)
