extends CharacterBody2D

@onready var visuals := $Visuals
@onready var velocity_component: VelocityComponent = $VelocityComponent
@onready var sprite: Sprite2D = $Visuals/Sprite2D
@onready var health_component: HealthComponent = $HealthComponent

var fire_timer := 0.0
var teleport_timer := 0.0
const FIRE_INTERVAL := 4.0
const TELEPORT_INTERVAL := 10.0
const TELEPORT_DISTANCE := 200.0
const FIRE_DAMAGE := 20.0
const FIRE_RADIUS := 150.0


func _ready():
	$HurtboxComponent.hit.connect(on_hit)
	health_component.died.connect(on_died)
	$HitboxComponent.damage = 15.0


func _process(delta):
	velocity_component.accelerate_to_player()
	velocity_component.move(self)
	
	var move_sign = sign(velocity.x)
	if move_sign != 0:
		visuals.scale = Vector2(-move_sign, 1)
	
	fire_timer += delta
	if fire_timer >= FIRE_INTERVAL:
		fire_timer = 0.0
		fire_aoe()
	
	teleport_timer += delta
	if teleport_timer >= TELEPORT_INTERVAL:
		teleport_timer = 0.0
		teleport_chase()


func fire_aoe():
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return
	
	var distance = global_position.distance_to(player.global_position)
	if distance <= FIRE_RADIUS:
		var health = player.get_node_or_null("HealthComponent") as HealthComponent
		if health:
			health.damage(FIRE_DAMAGE)
	
	modulate = Color(1.0, 0.3, 0.0, 1.0)
	await get_tree().create_timer(0.4).timeout
	modulate = Color.WHITE


func teleport_chase():
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return
	
	var direction = (player.global_position - global_position).normalized()
	global_position = player.global_position - direction * 80
	
	modulate = Color(0.5, 0.0, 1.0, 0.5)
	await get_tree().create_timer(0.2).timeout
	modulate = Color.WHITE


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
