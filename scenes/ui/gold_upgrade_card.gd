extends PanelContainer
class_name GoldUpgradeCard

@onready var name_label: Label = %NameLabel
@onready var description_label: Label = %DescriptionLabel
@onready var level_label: Label = %LevelLabel
@onready var cost_label: Label = %CostLabel
@onready var purchase_button: Button = %PurchaseButton

var upgrade_id: String
var upgrade_info: Dictionary


func _ready():
	purchase_button.pressed.connect(on_purchase_pressed)


func setup(stat_id: String, info: Dictionary):
	upgrade_id = stat_id
	upgrade_info = info
	name_label.text = info["title"]
	description_label.text = info["description"]
	update_display()


func update_display():
	var current_level = MetaProgression.get_stat_upgrade_level(upgrade_id)
	var max_level = upgrade_info["max_level"]
	var cost = MetaProgression.get_upgrade_cost(upgrade_id)
	var gold = MetaProgression.save_data["meta_gold"]

	level_label.text = "Lv %d/%d" % [current_level, max_level]
	cost_label.text = "%d G" % cost

	if current_level >= max_level:
		purchase_button.text = "已满"
		purchase_button.disabled = true
	else:
		purchase_button.text = "购买"
		purchase_button.disabled = gold < cost


func on_purchase_pressed():
	if MetaProgression.purchase_stat_upgrade(upgrade_id):
		get_tree().call_group("gold_upgrade_card", "update_display")
		$AnimationPlayer.play("selected")
