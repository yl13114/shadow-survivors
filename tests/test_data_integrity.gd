extends Node

var test_results: Array = []

func _ready():
	print("=== 数据完整性白盒测试 ===\n")
	run_all_tests()
	print_test_summary()


func run_all_tests():
	test_wb043_characters_json()
	test_wb044_evolutions_json()
	test_wb045_affixes_json()
	test_wb046_enemies_json()
	test_wb047_meta_upgrades_json()


func test_wb043_characters_json():
	var data = load_json("res://data/characters.json")
	var passed = data.has("characters") and data["characters"].size() > 0
	if passed:
		var knight = data["characters"][0]
		passed = knight.has("id") and knight.has("name") and knight.has("stats")
	add_result("WB-043", "characters.json 结构", passed, str(data.keys()))


func test_wb044_evolutions_json():
	var data = load_json("res://data/evolutions.json")
	var passed = data.has("evolutions") and data["evolutions"].size() == 10
	if passed:
		for evo in data["evolutions"]:
			if not (evo.has("base_weapon") and evo.has("required_item") and evo.has("evolved_weapon")):
				passed = false
				break
	add_result("WB-044", "evolutions.json 结构", passed, 
		"配方数:" + str(data.get("evolutions", []).size()))


func test_wb045_affixes_json():
	var data = load_json("res://data/affixes.json")
	var passed = data is Dictionary and data.size() >= 21
	if passed:
		for key in data.keys():
			var affix = data[key]
			if not (affix.has("name") and affix.has("type") and affix.has("value")):
				passed = false
				break
	add_result("WB-045", "affixes.json 结构", passed, 
		"词条数:" + str(data.size()))


func test_wb046_enemies_json():
	var data = load_json("res://data/enemies.json")
	var passed = data.has("enemies") and data["enemies"].size() > 0
	if passed:
		for enemy in data["enemies"]:
			if not (enemy.has("health") and enemy.has("damage") and enemy.has("speed")):
				passed = false
				break
	add_result("WB-046", "enemies.json 结构", passed, 
		"敌人数:" + str(data.get("enemies", []).size()))


func test_wb047_meta_upgrades_json():
	var data = load_json("res://data/meta_upgrades.json")
	var passed = data.has("upgrades") and data["upgrades"].size() == 6
	if passed:
		for upgrade in data["upgrades"]:
			if not (upgrade.has("id") and upgrade.has("max_level") and upgrade.has("base_cost")):
				passed = false
				break
	add_result("WB-047", "meta_upgrades.json 结构", passed, 
		"升级数:" + str(data.get("upgrades", []).size()))


func load_json(path: String) -> Dictionary:
	var file = FileAccess.open(path, FileAccess.READ)
	if not file:
		return {}
	var json = JSON.new()
	var error = json.parse(file.get_as_text())
	if error == OK:
		return json.data
	return {}


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
