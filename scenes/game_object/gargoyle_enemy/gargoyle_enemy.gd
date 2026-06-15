extends CharacterBody2D

@onready var visuals := $Visuals
@onready var velocity_component: VelocityComponent = $VelocityComponent

var is_diving := false
var dive_timer := 0.0
const DIVE_INTERVAL := 6.0
const DIVE_DURATION := 2.0
const DIVE_SPEED_MULT := 2.0


func _ready():
	$HurtboxComponent.hit.connect(on_hit)


func _process(delta):
	if not is_diving:
		velocity_component.accelerate_to_player()
		velocity_component.move(self)
	
	var move_sign = sign(velocity.x)
	if move_sign != 0:
		visuals.scale = Vector2(-move_sign, 1)
	
	dive_timer += delta
	if dive_timer >= DIVE_INTERVAL and not is_diving:
		dive_timer = 0.0
		is_diving = true
		velocity_component.max_speed = int(velocity_component.max_speed * DIVE_SPEED_MULT)
		modulate = Color(1.0, 0.8, 0.3, 1.0)
		await get_tree().create_timer(DIVE_DURATION).timeout
		is_diving = false
		velocity_component.max_speed = int(velocity_component.max_speed / DIVE_SPEED_MULT)
		modulate = Color.WHITE


func on_hit():
	$HitRandomAudioPlayerComponent.play_random()
