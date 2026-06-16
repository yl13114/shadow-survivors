extends Node

var weapon_evolution: WeaponEvolution
var test_results: Array = []

func _ready():
	print("=== 武器进化系统白盒测试 ===\n")
	weapon_evolution = WeaponEvolution.new()
	weapon_evolution._ready()
	run_all_tests()
	print_test_summary()


func run_all_tests():
	test_wb001_load_evolutions()
	test_wb002_can_evolve_success()
	test_wb003_can_evolve_not_max_level()
	test_wb004_can_evolve_no_item()
	test_wb005_can_evolve_nonexistent()
	test_wb006_evolve_success()
	test_wb007_get_required_item()
	test_wb008_get_evolution_info()


func test_wb001_load_evolutions():
	var passed = weapon_evolution.evolutions.size() == 10
	add_result("WB-001", "加载进化数据", passed, 
		"期望10条，实际" + str(weapon_evolution.evolutions.size()))


func test_wb002_can_evolve_success():
	var current_upgrades = {
		"holy_staff": {
			"quantity": 8,
			"resource": {"max_quantity": 8}
		},
		"holy_amulet": {
			"quantity": 1,
			"resource": {}
		}
	}
	var result = weapon_evolution.can_evolve("holy_staff", current_upgrades)
	add_result("WB-002", "武器可进化 - 满级+有道具", result, str(result))


func test_wb003_can_evolve_not_max_level():
	var current_upgrades = {
		"holy_staff": {
			"quantity": 5,
			"resource": {"max_quantity": 8}
		},
		"holy_amulet": {
			"quantity": 1,
			"resource": {}
		}
	}
	var result = weapon_evolution.can_evolve("holy_staff", current_upgrades)
	add_result("WB-003", "武器不可进化 - 未满级", not result, str(result))


func test_wb004_can_evolve_no_item():
	var current_upgrades = {
		"holy_staff": {
			"quantity": 8,
			"resource": {"max_quantity": 8}
		}
	}
	var result = weapon_evolution.can_evolve("holy_staff", current_upgrades)
	add_result("WB-004", "武器不可进化 - 无道具", not result, str(result))


func test_wb005_can_evolve_nonexistent():
	var current_upgrades = {}
	var result = weapon_evolution.can_evolve("nonexistent", current_upgrades)
	add_result("WB-005", "武器不可进化 - 不存在的武器", not result, str(result))


func test_wb006_evolve_success():
	var current_upgrades = {
		"holy_staff": {
			"quantity": 8,
			"resource": {"max_quantity": 8}
		},
		"holy_amulet": {
			"quantity": 1,
			"resource": {}
		}
	}
	var result = weapon_evolution.evolve("holy_staff", current_upgrades)
	var passed = result.has("evolved_weapon") and result["evolved_weapon"] == "angel_staff"
	add_result("WB-006", "执行进化", passed, str(result))


func test_wb007_get_required_item():
	var result = weapon_evolution.get_required_item("holy_staff")
	add_result("WB-007", "获取所需道具", result == "holy_amulet", result)


func test_wb008_get_evolution_info():
	var result = weapon_evolution.get_evolution_info("holy_staff")
	var passed = result.has("base_weapon") and result["base_weapon"] == "holy_staff"
	add_result("WB-008", "获取进化信息", passed, str(result))


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
