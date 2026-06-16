extends Node

var test_results: Array = []

func _ready():
	print("=== Meta进度系统白盒测试 ===\n")
	run_all_tests()
	print_test_summary()


func run_all_tests():
	test_wb026_get_upgrade_level()
	test_wb027_purchase_upgrade_success()
	test_wb028_purchase_upgrade_insufficient_gold()
	test_wb029_purchase_upgrade_max_level()
	test_wb030_get_upgrade_cost_level0()
	test_wb031_get_upgrade_cost_level5()
	test_wb032_get_stat_bonuses_default()
	test_wb033_get_stat_bonuses_with_upgrades()
	test_wb034_add_gold()
	test_wb035_add_gold_with_multiplier()


func test_wb026_get_upgrade_level():
	MetaProgression.save_data["stat_upgrades"] = {"max_health": 3}
	var level = MetaProgression.get_stat_upgrade_level("max_health")
	add_result("WB-026", "获取升级等级", level == 3, str(level))


func test_wb027_purchase_upgrade_success():
	MetaProgression.save_data["meta_gold"] = 1000
	MetaProgression.save_data["stat_upgrades"] = {}
	var result = MetaProgression.purchase_stat_upgrade("max_health")
	var gold_after = MetaProgression.save_data["meta_gold"]
	var level_after = MetaProgression.get_stat_upgrade_level("max_health")
	add_result("WB-027", "购买升级 - 成功", result and gold_after == 900 and level_after == 1, 
		"金币:" + str(gold_after) + " 等级:" + str(level_after))


func test_wb028_purchase_upgrade_insufficient_gold():
	MetaProgression.save_data["meta_gold"] = 50
	MetaProgression.save_data["stat_upgrades"] = {}
	var result = MetaProgression.purchase_stat_upgrade("max_health")
	add_result("WB-028", "购买升级 - 金币不足", not result, str(result))


func test_wb029_purchase_upgrade_max_level():
	MetaProgression.save_data["meta_gold"] = 10000
	MetaProgression.save_data["stat_upgrades"] = {"max_health": 20}
	var result = MetaProgression.purchase_stat_upgrade("max_health")
	add_result("WB-029", "购买升级 - 已满级", not result, str(result))


func test_wb030_get_upgrade_cost_level0():
	MetaProgression.save_data["stat_upgrades"] = {}
	var cost = MetaProgression.get_upgrade_cost("max_health")
	add_result("WB-030", "获取升级费用 - 等级0", cost == 100, str(cost))


func test_wb031_get_upgrade_cost_level5():
	MetaProgression.save_data["stat_upgrades"] = {"max_health": 5}
	var cost = MetaProgression.get_upgrade_cost("max_health")
	add_result("WB-031", "获取升级费用 - 等级5", cost == 600, str(cost))


func test_wb032_get_stat_bonuses_default():
	MetaProgression.save_data["stat_upgrades"] = {}
	var bonuses = MetaProgression.get_stat_bonuses()
	add_result("WB-032", "获取属性加成 - 默认", bonuses["max_health"] == 0.0 and bonuses["attack_power"] == 1.0, 
		str(bonuses))


func test_wb033_get_stat_bonuses_with_upgrades():
	MetaProgression.save_data["stat_upgrades"] = {"max_health": 3}
	var bonuses = MetaProgression.get_stat_bonuses()
	add_result("WB-033", "获取属性加成 - 有升级", bonuses["max_health"] == 30.0, 
		str(bonuses["max_health"]))


func test_wb034_add_gold():
	MetaProgression.save_data["meta_gold"] = 100
	MetaProgression.save_data["stat_upgrades"] = {}
	MetaProgression.add_gold(100)
	add_result("WB-034", "增加金币", MetaProgression.save_data["meta_gold"] == 200, 
		str(MetaProgression.save_data["meta_gold"]))


func test_wb035_add_gold_with_multiplier():
	MetaProgression.save_data["meta_gold"] = 100
	MetaProgression.save_data["stat_upgrades"] = {"gold_gain": 3}
	MetaProgression.add_gold(100)
	add_result("WB-035", "增加金币 - 有倍率", MetaProgression.save_data["meta_gold"] == 250, 
		str(MetaProgression.save_data["meta_gold"]))


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
