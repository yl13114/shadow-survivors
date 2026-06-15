extends CharacterBody2D

@onready var visuals := $Visuals
@onready var velocity_component: VelocityComponent = $VelocityComponent

var is_enraged := false
var rage_timer := 0.0
const RAGE_INTERVAL := 8.0
const RAGE_DURATION := 3.0
const RAGE_SPEED_MULT := 1.5


func _ready():
	$HurtboxComponent.hit.connect(on_hit)


func _process(delta):
	velocity_component.accelerate_to_player()
	velocity_component.move(self)
	
	var move_sign = sign(velocity.x)
	if move_sign != 0:
		visuals.scale = Vector2(-move_sign, 1)
	
	rage_timer += delta
	if rage_timer >= RAGE_INTERVAL and not is_enraged:
		rage_timer = 0.0
		is_enraged = true
		velocity_component.max_speed = int(velocity_component.max_speed * RAGE_SPEED_MULT)
		modulate = Color(1.0, 0.5, 0.5, 1.0)
		await get_tree().create_timer(RAGE_DURATION).timeout
		is_enraged = false
		velocity_component.max_speed = int(velocity_component.max_speed / RAGE_SPEED_MULT)
		modulate = Color.WHITE


func on_hit():
	$HitRandomAudioPlayerComponent.play_random()
