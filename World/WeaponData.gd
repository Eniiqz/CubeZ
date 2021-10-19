extends Node

var weapons = {
	"Pistol": {
		"price": 500,
		"damage": 25,
		"in_box": false,
	},
	"SMG": {
		"price": 1200,
		"damage": 25,
		"in_box": true,
		"ammo_price": 600
	}
}

#TODO: FIX THIS
func get_cost(weapon):
	if weapons.has(weapon):
		return weapons[weapon].price
		
func get_ammo_cost(weapon):
	if weapons.has(weapon):
		return weapons[weapon].ammo_price

func get_damage(weapon):
	if weapons.has(weapon):
		return weapons[weapon].damage

func get_box_status(weapon):
	if weapons.has(weapon):
		return weapons[weapon].in_box
