extends CharacterBody2D

@onready var visuals := $Visuals
@onready var velocity_component: VelocityComponent = $VelocityComponent
@onready var sprite: Sprite2D = $Visuals/Sprite2D
@onready var health_component: HealthComponent = $HealthComponent

var basic_enemy_scene = preload("res://scenes/game_object/basic_enemy/basic_enemy.tscn")
var summon_timer := 0.0
var spike_timer := 0.0
const SUMMON_INTERVAL := 8.0
const SPIKE_INTERVAL := 5.0
const SUMMON_COUNT := 3


func _ready():
	$HurtboxComponent.hit.connect(on_hit)
	health_component.died.connect(on_died)
	$HitboxComponent.damage = 10.0


func _process(delta):
	velocity_component.accelerate_to_player()
	velocity_component.move(self)
	
	var move_sign = sign(velocity.x)
	if move_sign != 0:
		visuals.scale = Vector2(-move_sign, 1)
	
	summon_timer += delta
	if summon_timer >= SUMMON_INTERVAL:
		summon_timer = 0.0
		summon_skeletons()
	
	spike_timer += delta
	if spike_timer >= SPIKE_INTERVAL:
		spike_timer = 0.0
		ground_spike()


func summon_skeletons():
	for i in SUMMON_COUNT:
		var enemy = basic_enemy_scene.instantiate() as Node2D
		var entities_layer = get_tree().get_first_node_in_group("entities_layer")
		entities_layer.add_child(enemy)
		
		var angle = randf() * TAU
		var distance = randf_range(50, 150)
		enemy.global_position = global_position + Vector2(cos(angle), sin(angle)) * distance
		
		var health = enemy.get_node("HealthComponent") as HealthComponent
		if health:
			health.max_health = 8.0
			health.current_health = 8.0
	
	modulate = Color(1.0, 0.5, 0.5, 1.0)
	await get_tree().create_timer(0.3).timeout
	modulate = Color.WHITE


func ground_spike():
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return
	
	var direction = (player.global_position - global_position).normalized()
	var spike_position = global_position + direction * 100
	
	var hitbox = $HitboxComponent as HitboxComponent
	if hitbox:
		hitbox.damage = 15.0
	
	modulate = Color(1.0, 0.8, 0.3, 1.0)
	await get_tree().create_timer(0.2).timeout
	modulate = Color.WHITE
	hitbox.damage = 10.0


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
