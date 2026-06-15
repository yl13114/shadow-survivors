extends Node


@export var end_screen_scene: PackedScene

var paused_menu_scene = preload("res://scenes/ui/pause_menu.tscn")


func _ready():
	%Player.health_component.died.connect(on_player_died)
	apply_meta_bonuses()


func apply_meta_bonuses():
	var bonuses = MetaProgression.get_stat_bonuses()
	var player = %Player

	# Apply max health
	if bonuses["max_health"] > 0:
		player.health_component.max_health = 10 + bonuses["max_health"]
		player.health_component.current_health = player.health_component.max_health

	# Apply move speed
	if bonuses["move_speed"] > 1.0:
		player.velocity_component.max_speed = player.base_speed * bonuses["move_speed"]

	# Apply armor (damage reduction)
	if bonuses["armor"] > 0:
		player.armor = bonuses["armor"]



func _unhandled_input(event):
	if event.is_action_pressed("pause"):
		add_child(paused_menu_scene.instantiate())
		get_tree().root.set_input_as_handled()


func on_player_died():
	var end_screen_instance = end_screen_scene.instantiate() as EndScreen
	add_child(end_screen_instance)
	end_screen_instance.set_defeat()
	MetaProgression.save()
