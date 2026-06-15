extends Node

# 10px outside
const SPAWN_RADIUS = 375

@export var basic_enemy_scene: PackedScene
@export var wizard_enemy_scene: PackedScene
@export var bat_enemy_scene: PackedScene
@export var zombie_enemy_scene: PackedScene
@export var spider_enemy_scene: PackedScene
@export var ghost_enemy_scene: PackedScene
@export var werewolf_enemy_scene: PackedScene
@export var gargoyle_enemy_scene: PackedScene
@export var skeleton_king_scene: PackedScene
@export var demon_lord_scene: PackedScene
@export var undead_lich_scene: PackedScene
@export var arena_time_manager: ArenaTimeManager

@onready var timer = $Timer

var base_spawn_time = 0  # sec
var enemy_table = WeightedTable.new()
var current_wave = 0
var boss_spawned = {}


func _ready():
	enemy_table.add_item(basic_enemy_scene, 10)
	base_spawn_time = timer.wait_time
	timer.timeout.connect(on_timer_timeout)
	arena_time_manager.arena_difficulty_increased.connect(on_arena_difficulty_increased)


func get_spawn_position() -> Vector2:
	# Spawn outside of the view
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return Vector2.ZERO

	var spawn_position: Vector2
	var random_direction := Vector2.RIGHT.rotated(randf_range(0, TAU))
	for i in 4:
		spawn_position = player.global_position + (random_direction * SPAWN_RADIUS)
		var additional_check_offset = random_direction * 20  # prevent stuck in a wall

		# raycast check
		var query_parameters = PhysicsRayQueryParameters2D.create(player.global_position, spawn_position + additional_check_offset, 1 << 0)
		var result = get_tree().root.world_2d.direct_space_state.intersect_ray(query_parameters)

		if result.is_empty():
			# no collision - OK
			return spawn_position

		random_direction = random_direction.rotated(deg_to_rad(90))

	return Vector2.ZERO


func on_timer_timeout():
	timer.start()

	var player = get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return
	
	var enemy_scnee = enemy_table.pick_item()
	var enemy = enemy_scnee.instantiate() as Node2D
	
	var entities_layer = get_tree().get_first_node_in_group("entities_layer")
	entities_layer.add_child(enemy)
	enemy.global_position = get_spawn_position()


func on_arena_difficulty_increased(arena_difficulty: int):
	current_wave = arena_difficulty
	update_enemy_table_for_wave(arena_difficulty)
	spawn_boss_for_wave(arena_difficulty)


func update_enemy_table_for_wave(wave: int):
	enemy_table = WeightedTable.new()
	
	match wave:
		0:
			enemy_table.add_item(basic_enemy_scene, 10)
			enemy_table.add_item(bat_enemy_scene, 8)
		1:
			enemy_table.add_item(basic_enemy_scene, 8)
			enemy_table.add_item(bat_enemy_scene, 6)
			enemy_table.add_item(zombie_enemy_scene, 7)
			enemy_table.add_item(spider_enemy_scene, 6)
		2:
			enemy_table.add_item(basic_enemy_scene, 6)
			enemy_table.add_item(zombie_enemy_scene, 6)
			enemy_table.add_item(spider_enemy_scene, 5)
			enemy_table.add_item(ghost_enemy_scene, 5)
			enemy_table.add_item(werewolf_enemy_scene, 4)
		3:
			enemy_table.add_item(zombie_enemy_scene, 5)
			enemy_table.add_item(spider_enemy_scene, 5)
			enemy_table.add_item(ghost_enemy_scene, 5)
			enemy_table.add_item(werewolf_enemy_scene, 5)
			enemy_table.add_item(gargoyle_enemy_scene, 4)
			enemy_table.add_item(wizard_enemy_scene, 4)
		4:
			enemy_table.add_item(werewolf_enemy_scene, 6)
			enemy_table.add_item(gargoyle_enemy_scene, 5)
			enemy_table.add_item(ghost_enemy_scene, 4)


func spawn_boss_for_wave(wave: int):
	if wave == 2 and not boss_spawned.has(2):
		boss_spawned[2] = true
		spawn_boss(skeleton_king_scene)
	elif wave == 3 and not boss_spawned.has(3):
		boss_spawned[3] = true
		spawn_boss(demon_lord_scene)
	elif wave == 4 and not boss_spawned.has(4):
		boss_spawned[4] = true
		spawn_boss(undead_lich_scene)


func spawn_boss(boss_scene: PackedScene):
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return
	
	var boss = boss_scene.instantiate() as Node2D
	var entities_layer = get_tree().get_first_node_in_group("entities_layer")
	entities_layer.add_child(boss)
	
	var angle = randf() * TAU
	boss.global_position = player.global_position + Vector2(cos(angle), sin(angle)) * SPAWN_RADIUS
