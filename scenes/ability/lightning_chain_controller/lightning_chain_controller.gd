extends Node

@export var lightning_chain_scene: PackedScene

var base_damage = 12
var additional_damage_percent: float = 1.0
var base_wait_time


func _ready():
	base_wait_time = $Timer.wait_time
	$Timer.timeout.connect(on_timer_timeout)
	GameEvents.ability_upgrade_added.connect(on_ability_upgrade_added)


func on_timer_timeout():
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return

	var enemies = get_tree().get_nodes_in_group("enemy")
	if enemies.is_empty():
		return

	enemies.sort_custom(func(a: Node2D, b: Node2D):
		var a_distance = a.global_position.distance_squared_to(player.global_position)
		var b_distance = b.global_position.distance_squared_to(player.global_position)
		return a_distance < b_distance
	)

	var lightning_instance = lightning_chain_scene.instantiate() as LightningChain
	var foreground_layer = get_tree().get_first_node_in_group("foreground_layer")
	foreground_layer.add_child(lightning_instance)
	lightning_instance.setup(player.global_position, enemies[0], base_damage * additional_damage_percent)


func on_ability_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary):
	match upgrade.id:
		"lightning_chain":
			additional_damage_percent = 1 + (current_upgrades["lightning_chain"]["quantity"] * 0.2)
