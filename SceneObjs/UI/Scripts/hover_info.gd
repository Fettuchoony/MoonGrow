class_name HoverInfo extends Control

@onready var _panel = $Panel
@onready var _item_name : Label = $Panel/ScrollContainer/LabelContainer/ItemName
@onready var _item_info : Label = $Panel/ScrollContainer/LabelContainer/ItemInfo
@onready var _stats_field : Label = $Panel/ScrollContainer/LabelContainer/Statsfield
@onready var _label_container : VBoxContainer = $Panel/ScrollContainer/LabelContainer
@onready var _label_array : Array[Node]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_panel.global_position = get_screen_transform() * get_local_mouse_position()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_panel.global_position = get_screen_transform() * get_local_mouse_position()

# Called with after adding this to scene tree. ie: add_child(this HoverInfo) then HoverInfo.update_data(corresponding Item)
func update_data(item : Item = null) -> void:
	_item_name.text = item.item_name
	
	
	# Item class specific actions TODO: Add more cases for any new item classes, like probably going to add active items at some point
	_label_array = _label_container.get_children()
	if item is ProjectileModifier:
		pass
	elif item is ProjectileSpawner:
		pass
	elif item is SpecialModifier:
		pass
