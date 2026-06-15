extends CanvasLayer
class_name GoldUpgradeMenu

@onready var grid_container: GridContainer = %GridContainer
@onready var back_button: Button = %BackButton
@onready var gold_label: Label = %GoldLabel

var gold_upgrade_card_scene = preload("res://scenes/ui/gold_upgrade_card.tscn")


func _ready():
	back_button.pressed.connect(on_back_pressed)

	for child in grid_container.get_children():
		child.queue_free()

	var upgrades = MetaProgression.meta_upgrades_data.get("upgrades", [])
	for info in upgrades:
		var card = gold_upgrade_card_scene.instantiate() as GoldUpgradeCard
		grid_container.add_child(card)
		card.setup(info["id"], info)

	update_gold_display()


func update_gold_display():
	gold_label.text = "%d G" % MetaProgression.save_data["meta_gold"]


func on_back_pressed():
	ScreenTransition.transition_to_scene("res://scenes/ui/main_menu.tscn")
