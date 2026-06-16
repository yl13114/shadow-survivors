extends Node

var equipment_system: EquipmentSystem
var test_results: Array = []

func _ready():
	print("=== 装备词条系统白盒测试 ===\n")
	equipment_system = EquipmentSystem.new()
	equipment_system._ready()
	run_all_tests()
	print_test_summary()


func run_all_tests():
	test_wb009_equip_empty_slot()
	test_wb010_equip_replace()
	test_wb011_equip_invalid_slot()
	test_wb012_unequip()
	test_wb013_get_equipped()
	test_wb014_generate_random_item()
	test_wb016_rarity_affix_count_common()
	test_wb017_rarity_affix_count_uncommon()
	test_wb018_rarity_affix_count_rare()
	test_wb019_rarity_affix_count_epic()
	test_wb020_rarity_affix_count_legendary()
	test_wb021_stat_calculation_speed()
	test_wb022_stat_calculation_stack()


func test_wb009_equip_empty_slot():
	var item = {"rarity": "rare", "affixes": [{"type": "move_speed_bonus", "value": 0.1}]}
	var old_item = equipment_system.equip(item, 0)
	var equipped = equipment_system.get_equipped(0)
	var passed = old_item.is_empty() and equipped["rarity"] == item["rarity"]
	add_result("WB-009", "装备物品到空槽", passed, str(old_item))


func test_wb010_equip_replace():
	var item1 = {"rarity": "common", "affixes": []}
	var item2 = {"rarity": "rare", "affixes": [{"type": "move_speed_bonus", "value": 0.1}]}
	equipment_system.equip(item1, 0)
	var old_item = equipment_system.equip(item2, 0)
	var equipped = equipment_system.get_equipped(0)
	var passed = old_item["rarity"] == item1["rarity"] and equipped["rarity"] == item2["rarity"]
	add_result("WB-010", "装备物品替换", passed, str(old_item))


func test_wb011_equip_invalid_slot():
	var item = {"rarity": "common", "affixes": []}
	var result1 = equipment_system.equip(item, -1)
	var result2 = equipment_system.equip(item, 5)
	add_result("WB-011", "无效槽位装备", result1.is_empty() and result2.is_empty(), "OK")


func test_wb012_unequip():
	var item = {"rarity": "rare", "affixes": [{"type": "move_speed_bonus", "value": 0.1}]}
	equipment_system.equip(item, 0)
	var removed = equipment_system.unequip(0)
	var passed = removed["rarity"] == item["rarity"] and equipment_system.get_equipped(0).is_empty()
	add_result("WB-012", "卸下装备", passed, str(removed))


func test_wb013_get_equipped():
	var item = {"rarity": "epic", "affixes": []}
	equipment_system.equip(item, 2)
	var result = equipment_system.get_equipped(2)
	add_result("WB-013", "获取已装备物品", result["rarity"] == item["rarity"], str(result))


func test_wb014_generate_random_item():
	var item = equipment_system.generate_random_item(0)
	var passed = item.has("slot") and item.has("rarity") and item.has("affixes")
	add_result("WB-014", "生成随机物品", passed, str(item))


func test_wb016_rarity_affix_count_common():
	var affixes = equipment_system._roll_affixes(0)
	add_result("WB-016", "词条数量 - common", affixes.size() == 0, str(affixes.size()))


func test_wb017_rarity_affix_count_uncommon():
	var affixes = equipment_system._roll_affixes(1)
	add_result("WB-017", "词条数量 - uncommon", affixes.size() == 1, str(affixes.size()))


func test_wb018_rarity_affix_count_rare():
	var affixes = equipment_system._roll_affixes(2)
	add_result("WB-018", "词条数量 - rare", affixes.size() == 2, str(affixes.size()))


func test_wb019_rarity_affix_count_epic():
	var affixes = equipment_system._roll_affixes(3)
	add_result("WB-019", "词条数量 - epic", affixes.size() == 3, str(affixes.size()))


func test_wb020_rarity_affix_count_legendary():
	var affixes = equipment_system._roll_affixes(3)
	add_result("WB-020", "词条数量 - legendary", affixes.size() == 3, str(affixes.size()))


func test_wb021_stat_calculation_speed():
	equipment_system.equipped_items[0] = {
		"rarity": "rare",
		"affixes": [{"type": "move_speed_bonus", "value": 0.1}]
	}
	var stats = equipment_system._calculate_total_stats()
	add_result("WB-021", "属性计算 - 移速加成", stats["move_speed_bonus"] == 0.1, str(stats["move_speed_bonus"]))


func test_wb022_stat_calculation_stack():
	equipment_system.equipped_items[0] = {
		"rarity": "rare",
		"affixes": [{"type": "move_speed_bonus", "value": 0.1}]
	}
	equipment_system.equipped_items[1] = {
		"rarity": "rare",
		"affixes": [{"type": "move_speed_bonus", "value": 0.1}]
	}
	var stats = equipment_system._calculate_total_stats()
	add_result("WB-022", "属性计算 - 多装备叠加", stats["move_speed_bonus"] == 0.2, str(stats["move_speed_bonus"]))


func add_result(id: String, name: String, passed: bool, detail: String):
	test_results.append({
		"id": id,
		"name": name,
		"passed": passed,
		"detail": detail
	})
	var status = "✅" if passed else "❌"
	print(status + " " + id + ": " + name + " - " + detail)


func print_test_summary():
	var passed_count = 0
	var failed_count = 0
	for result in test_results:
		if result["passed"]:
			passed_count += 1
		else:
			failed_count += 1
	
	print("\n=== 测试总结 ===")
	print("通过: " + str(passed_count))
	print("失败: " + str(failed_count))
	print("总计: " + str(test_results.size()))
