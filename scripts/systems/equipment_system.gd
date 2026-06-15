extends Node
class_name EquipmentSystem

signal equipment_changed(slot: int, item: Dictionary)

const SLOT_NAMES = ["helmet", "chest", "legs", "accessory"]
const SLOT_COUNT = 4

const RARITY_COLORS = {
	"common": Color.WHITE,
	"uncommon": Color.GREEN,
	"rare": Color.BLUE,
	"epic": Color.PURPLE,
	"legendary": Color.ORANGE,
}

const RARITY_AFFIX_COUNTS = {
	"common": 0,
	"uncommon": 1,
	"rare": 2,
	"epic": 3,
	"legendary": 3,
}

const RARITY_WEIGHTS = {
	"common": 50,
	"uncommon": 25,
	"rare": 15,
	"epic": 8,
	"legendary": 2,
}

var equipped_items: Array[Dictionary] = []
var affixes_data: Dictionary = {}
var equipment_data: Dictionary = {}
var player_node: CharacterBody2D = null


func _ready():
	equipped_items.resize(SLOT_COUNT)
	equipped_items.fill({})
	_load_data()


func _load_data():
	var affixes_file = FileAccess.open("res://data/affixes.json", FileAccess.READ)
	if affixes_file:
		affixes_data = JSON.parse_string(affixes_file.get_as_text())

	var equip_file = FileAccess.open("res://data/equipment.json", FileAccess.READ)
	if equip_file:
		equipment_data = JSON.parse_string(equip_file.get_as_text())


func set_player(player: CharacterBody2D):
	player_node = player


func equip(item: Dictionary, slot: int) -> Dictionary:
	if slot < 0 or slot >= SLOT_COUNT:
		return {}

	var old_item = equipped_items[slot]
	equipped_items[slot] = item
	_apply_all_effects()
	equipment_changed.emit(slot, item)
	return old_item


func unequip(slot: int) -> Dictionary:
	if slot < 0 or slot >= SLOT_COUNT:
		return {}

	var old_item = equipped_items[slot]
	equipped_items[slot] = {}
	_apply_all_effects()
	equipment_changed.emit(slot, {})
	return old_item


func get_equipped(slot: int) -> Dictionary:
	if slot < 0 or slot >= SLOT_COUNT:
		return {}
	return equipped_items[slot]


func get_all_equipped() -> Array[Dictionary]:
	return equipped_items.duplicate()


func generate_random_item(slot: int) -> Dictionary:
	var rarity = _roll_rarity()
	var affix_count = RARITY_AFFIX_COUNTS[rarity]
	var affixes = _roll_affixes(affix_count)

	return {
		"slot": SLOT_NAMES[slot],
		"rarity": rarity,
		"affixes": affixes,
	}


func generate_random_item_from_chest() -> Dictionary:
	var slot = randi() % SLOT_COUNT
	return generate_random_item(slot)


func _roll_rarity() -> String:
	var total_weight = 0
	for rarity in RARITY_WEIGHTS:
		total_weight += RARITY_WEIGHTS[rarity]

	var roll = randf() * total_weight
	var cumulative = 0.0
	for rarity in RARITY_WEIGHTS:
		cumulative += RARITY_WEIGHTS[rarity]
		if roll <= cumulative:
			return rarity

	return "common"


func _roll_affixes(count: int) -> Array[Dictionary]:
	if count <= 0:
		return []

	var all_affix_keys = affixes_data.keys()
	if all_affix_keys.is_empty():
		return []

	var result: Array[Dictionary] = []
	var used_keys: Array = []

	for i in count:
		var available = all_affix_keys.filter(func(k): return k not in used_keys)
		if available.is_empty():
			break
		var key = available[randi() % available.size()]
		used_keys.append(key)
		var affix = affixes_data[key].duplicate()
		affix["id"] = key
		result.append(affix)

	return result


func _apply_all_effects():
	if player_node == null:
		return

	var stats = _calculate_total_stats()
	_apply_stats_to_player(stats)


func _calculate_total_stats() -> Dictionary:
	var stats = {
		"move_speed_bonus": 0.0,
		"max_health_bonus": 0.0,
		"armor_bonus": 0.0,
		"crit_rate": 0.0,
		"crit_damage": 0.0,
		"attack_speed": 0.0,
		"damage_multiplier": 1.0,
		"life_on_kill": 0.0,
		"exp_bonus": 0.0,
		"gold_bonus": 0.0,
		"pickup_range": 0.0,
		"chest_drop_rate": 0.0,
	}

	for item in equipped_items:
		if item.is_empty():
			continue
		for affix in item.get("affixes", []):
			_apply_affix(affix, stats)

	return stats


func _apply_affix(affix: Dictionary, stats: Dictionary):
	var affix_type = affix.get("type", "")
	var value = affix.get("value", 0.0)

	match affix_type:
		"move_speed_bonus":
			stats["move_speed_bonus"] += value
		"max_health_bonus":
			stats["max_health_bonus"] += value
		"armor_bonus":
			stats["armor_bonus"] += value
		"crit_rate":
			stats["crit_rate"] += value
		"crit_damage":
			stats["crit_damage"] += value
		"attack_speed":
			stats["attack_speed"] += value
		"damage_multiplier":
			stats["damage_multiplier"] += value
		"life_on_kill":
			stats["life_on_kill"] += value
		"exp_bonus":
			stats["exp_bonus"] += value
		"gold_bonus":
			stats["gold_bonus"] += value
		"pickup_range":
			stats["pickup_range"] += value
		"chest_drop_rate":
			stats["chest_drop_rate"] += value


func _apply_stats_to_player(stats: Dictionary):
	if player_node == null:
		return

	if player_node.has_method("get") and player_node.get("velocity_component"):
		var vc = player_node.velocity_component
		if vc:
			vc.max_speed = player_node.base_speed + (player_node.base_speed * stats["move_speed_bonus"])

	if player_node.has_method("get") and player_node.get("health_component"):
		var hc = player_node.health_component
		if hc:
			hc.max_health = 10 + stats["max_health_bonus"]
			hc.current_health = min(hc.current_health, hc.max_health)
