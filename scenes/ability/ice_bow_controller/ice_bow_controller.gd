extends Node

@export var ice_bow_scene: PackedScene

var base_damage = 8
var additional_damage_percent: float = 1.0
var slow_amount: float = 0.5
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

	var ice_bow_instance = ice_bow_scene.instantiate() as IceBow
	var foreground_layer = get_tree().get_first_node_in_group("foreground_layer")
	foreground_layer.add_child(ice_bow_instance)
	ice_bow_instance.global_position = player.global_position
	ice_bow_instance.direction = (enemies[0].global_position - player.global_position).normalized()
	ice_bow_instance.hitbox_component.damage = base_damage * additional_damage_percent


func on_ability_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary):
	match upgrade.id:
		"ice_bow_rate":
			var percent_reduction = current_upgrades["ice_bow_rate"]["quantity"] * 0.1
			$Timer.wait_time = base_wait_time * (1 - percent_reduction)
			$Timer.start()
		"ice_bow_damage":
			additional_damage_percent = 1 + (current_upgrades["ice_bow_damage"]["quantity"] * 0.15)
