extends Node2D
class_name LightningChain

const CHAIN_RANGE = 150
const MAX_BOUNCES = 3

var damage: float = 10
var current_bounce: int = 0
var hit_enemies: Array[Node2D] = []


func _ready():
	var tween = create_tween()
	tween.tween_callback(queue_free).set_delay(0.3)


func setup(start_position: Vector2, target: Node2D, dmg: float):
	global_position = start_position
	damage = dmg
	if target:
		hit_enemies.append(target)
		deal_damage(target)
		chain_to_next(target)


func deal_damage(enemy: Node2D):
	var health_component = enemy.get_node_or_null("HealthComponent")
	if health_component:
		health_component.damage(damage)


func chain_to_next(last_enemy: Node2D):
	if current_bounce >= MAX_BOUNCES:
		return

	var enemies = get_tree().get_nodes_in_group("enemy")
	var closest_enemy: Node2D = null
	var closest_distance: float = CHAIN_RANGE * CHAIN_RANGE

	for enemy in enemies:
		if enemy in hit_enemies:
			continue
		var dist_sq = enemy.global_position.distance_squared_to(last_enemy.global_position)
		if dist_sq < closest_distance:
			closest_distance = dist_sq
			closest_enemy = enemy

	if closest_enemy:
		hit_enemies.append(closest_enemy)
		current_bounce += 1
		deal_damage(closest_enemy)
		chain_to_next(closest_enemy)
