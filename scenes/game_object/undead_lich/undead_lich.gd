extends CharacterBody2D

@onready var visuals := $Visuals
@onready var velocity_component: VelocityComponent = $VelocityComponent
@onready var sprite: Sprite2D = $Visuals/Sprite2D
@onready var health_component: HealthComponent = $HealthComponent

var revive_timer := 0.0
var curse_timer := 0.0
const REVIVE_INTERVAL := 12.0
const CURSE_INTERVAL := 6.0
const CURSE_DURATION := 4.0
const CURSE_SLOW_MULT := 0.4


func _ready():
	$HurtboxComponent.hit.connect(on_hit)
	health_component.died.connect(on_died)
	$HitboxComponent.damage = 20.0


func _process(delta):
	velocity_component.accelerate_to_player()
	velocity_component.move(self)
	
	var move_sign = sign(velocity.x)
	if move_sign != 0:
		visuals.scale = Vector2(-move_sign, 1)
	
	revive_timer += delta
	if revive_timer >= REVIVE_INTERVAL:
		revive_timer = 0.0
		revive_monsters()
	
	curse_timer += delta
	if curse_timer >= CURSE_INTERVAL:
		curse_timer = 0.0
		slow_curse()


func revive_monsters():
	var enemies = get_tree().get_nodes_in_group("enemy")
	var dead_count := 0
	
	for enemy in enemies:
		if enemy == self:
			continue
		var health = enemy.get_node_or_null("HealthComponent") as HealthComponent
		if health and health.current_health <= 0:
			health.current_health = health.max_health * 0.5
			health.health_changed.emit()
			dead_count += 1
	
	modulate = Color(0.5, 0.0, 1.0, 1.0)
	await get_tree().create_timer(0.5).timeout
	modulate = Color.WHITE


func slow_curse():
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return
	
	var velocity_comp = player.get_node_or_null("VelocityComponent") as VelocityComponent
	if velocity_comp:
		var original_speed = velocity_comp.max_speed
		velocity_comp.max_speed = int(original_speed * CURSE_SLOW_MULT)
		
		modulate = Color(0.3, 0.0, 0.8, 1.0)
		await get_tree().create_timer(CURSE_DURATION).timeout
		modulate = Color.WHITE
		
		velocity_comp.max_speed = original_speed


func on_hit():
	$HitRandomAudioPlayerComponent.play_random()
	modulate = Color(1.0, 0.3, 0.3, 1.0)
	await get_tree().create_timer(0.1).timeout
	modulate = Color.WHITE


func on_died():
	var spawn_position = global_position
	var entities = get_tree().get_first_node_in_group("entities_layer")
	get_parent().remove_child(self)
	entities.add_child(self)
	global_position = spawn_position
	$DeathComponent/AnimationPlayer.play("default")
	$DeathComponent/HitRandomAudioPlayerComponent.play_random()
