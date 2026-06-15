extends CharacterBody2D

@onready var visuals := $Visuals
@onready var velocity_component: VelocityComponent = $VelocityComponent
@onready var sprite: Sprite2D = $Visuals/Sprite2D

var is_phasing := false
var phase_timer := 0.0
const PHASE_INTERVAL := 3.0
const PHASE_DURATION := 1.0


func _ready():
	$HurtboxComponent.hit.connect(on_hit)


func _process(delta):
	velocity_component.accelerate_to_player()
	velocity_component.move(self)
	
	var move_sign = sign(velocity.x)
	if move_sign != 0:
		visuals.scale = Vector2(-move_sign, 1)
	
	phase_timer += delta
	if phase_timer >= PHASE_INTERVAL:
		phase_timer = 0.0
		is_phasing = true
		modulate = Color(1, 1, 1, 0.5)
		$HurtboxComponent.set_deferred("monitoring", false)
		await get_tree().create_timer(PHASE_DURATION).timeout
		is_phasing = false
		modulate = Color.WHITE
		$HurtboxComponent.monitoring = true


func on_hit():
	$HitRandomAudioPlayerComponent.play_random()
