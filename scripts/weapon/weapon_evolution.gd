extends Node
class_name WeaponEvolution

var evolutions: Array = []

func _ready():
	load_evolutions()


func load_evolutions():
	var file = FileAccess.open("res://data/evolutions.json", FileAccess.READ)
	if file == null:
		push_error("Failed to load evolutions.json")
		return
	var json = JSON.new()
	var error = json.parse(file.get_as_text())
	if error != OK:
		push_error("Failed to parse evolutions.json: " + json.get_error_message())
		return
	var data = json.data
	if data.has("evolutions"):
		evolutions = data["evolutions"]


func can_evolve(weapon_id: String, current_upgrades: Dictionary) -> bool:
	for evolution in evolutions:
		if evolution["base_weapon"] == weapon_id:
			if _has_required_item(evolution["required_item"], current_upgrades):
				if _is_weapon_max_level(weapon_id, current_upgrades):
					return true
	return false


func evolve(weapon_id: String, current_upgrades: Dictionary) -> Dictionary:
	for evolution in evolutions:
		if evolution["base_weapon"] == weapon_id:
			if can_evolve(weapon_id, current_upgrades):
				return {
					"evolved_weapon": evolution["evolved_weapon"],
					"required_item": evolution["required_item"],
					"description": evolution["description"]
				}
	return {}


func get_required_item(weapon_id: String) -> String:
	for evolution in evolutions:
		if evolution["base_weapon"] == weapon_id:
			return evolution["required_item"]
	return ""


func get_evolution_info(weapon_id: String) -> Dictionary:
	for evolution in evolutions:
		if evolution["base_weapon"] == weapon_id:
			return evolution
	return {}


func _has_required_item(item_id: String, current_upgrades: Dictionary) -> bool:
	return current_upgrades.has(item_id)


func _is_weapon_max_level(weapon_id: String, current_upgrades: Dictionary) -> bool:
	if not current_upgrades.has(weapon_id):
		return false
	var upgrade_data = current_upgrades[weapon_id]
	var quantity = upgrade_data["quantity"]
	var resource = upgrade_data["resource"]
	if resource.max_quantity > 0:
		return quantity >= resource.max_quantity
	return quantity >= 8
