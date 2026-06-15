extends Node2D
class_name IceBow

const SPEED = 300
const MAX_RANGE = 400

@onready var hitbox_component: HitboxComponent = $HitboxComponent

var direction: Vector2
var distance_traveled: float = 0


func _ready():
	var tween = create_tween()
	tween.tween_callback(queue_free).set_delay(1.5)


func _process(delta):
	var movement = direction * SPEED * delta
	global_position += movement
	distance_traveled += movement.length()
