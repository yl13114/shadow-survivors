extends Node

const SAVE_FILE_PATH := "user://game.save"
const META_UPGRADES_PATH := "res://data/meta_upgrades.json"

var save_data: Dictionary = {
	"meta_upgrade_currency": 0,
	"meta_upgrades": {},
	"meta_gold": 0,
	"stat_upgrades": {},
}

var meta_upgrades_data: Dictionary = {}


func _ready():
	GameEvents.experience_vial_collected.connect(on_experience_collected)
	load_save_file()
	load_meta_upgrades_data()


func load_save_file():
	if !FileAccess.file_exists(SAVE_FILE_PATH):
		return

	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	save_data = file.get_var()

	# Ensure new fields exist for backwards compatibility
	if !save_data.has("meta_gold"):
		save_data["meta_gold"] = 0
	if !save_data.has("stat_upgrades"):
		save_data["stat_upgrades"] = {}


func save():
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	file.store_var(save_data)


func load_meta_upgrades_data():
	var file = FileAccess.open(META_UPGRADES_PATH, FileAccess.READ)
	if file:
		var text = file.get_as_text()
		var json = JSON.new()
		var error = json.parse(text)
		if error == OK:
			meta_upgrades_data = json.data


func get_upgrade_count(upgrade_id: String) -> int:
	if save_data["meta_upgrades"].has(upgrade_id):
		return save_data["meta_upgrades"][upgrade_id]["quantity"]
	return 0


func add_meta_upgrade(upgrade: MetaUpgrade):
	if !save_data["meta_upgrades"].has(upgrade.id):
		save_data["meta_upgrades"][upgrade.id] = {
			"quantity": 0
		}

	save_data["meta_upgrades"][upgrade.id]["quantity"] += 1
	save()


func get_stat_upgrade_level(stat_id: String) -> int:
	if save_data["stat_upgrades"].has(stat_id):
		return save_data["stat_upgrades"][stat_id]
	return 0


func purchase_stat_upgrade(stat_id: String) -> bool:
	var upgrade_info = _get_upgrade_info(stat_id)
	if upgrade_info.is_empty():
		return false

	var current_level = get_stat_upgrade_level(stat_id)
	if current_level >= upgrade_info["max_level"]:
		return false

	var cost = upgrade_info["base_cost"] + (upgrade_info["cost_per_level"] * current_level)
	if save_data["meta_gold"] < cost:
		return false

	save_data["meta_gold"] -= cost
	save_data["stat_upgrades"][stat_id] = current_level + 1
	save()
	return true


func get_upgrade_cost(stat_id: String) -> int:
	var upgrade_info = _get_upgrade_info(stat_id)
	if upgrade_info.is_empty():
		return 0

	var current_level = get_stat_upgrade_level(stat_id)
	return upgrade_info["base_cost"] + (upgrade_info["cost_per_level"] * current_level)


func _get_upgrade_info(stat_id: String) -> Dictionary:
	for upgrade in meta_upgrades_data.get("upgrades", []):
		if upgrade["id"] == stat_id:
			return upgrade
	return {}


func get_stat_bonuses() -> Dictionary:
	var bonuses = {
		"max_health": 0.0,
		"attack_power": 1.0,
		"move_speed": 1.0,
		"exp_gain": 1.0,
		"gold_gain": 1.0,
		"armor": 0.0,
	}

	for stat_id in bonuses.keys():
		var level = get_stat_upgrade_level(stat_id)
		if level > 0:
			var info = _get_upgrade_info(stat_id)
			if !info.is_empty():
				bonuses[stat_id] += info["value_per_level"] * level

	return bonuses


func add_gold(amount: int):
	var bonuses = get_stat_bonuses()
	var modified_amount = int(amount * bonuses["gold_gain"])
	save_data["meta_gold"] += modified_amount
	save()


func on_experience_collected(number: float):
	save_data["meta_upgrade_currency"] += number
