class_name HoverInfo extends Control

@onready var _panel = $Panel
@onready var _quality : float = 0.0
@onready var _quality_mult : float = 0.0
@onready var _quality_label : RichTextLabel = $Quality
@onready var _quality_color : Color = Color.WHITE
@onready var _item_name : Label = $Panel/ScrollContainer/LabelContainer/ItemName
@onready var _item_info : Label = $Panel/ScrollContainer/LabelContainer/ItemInfo
@onready var _label_container : VBoxContainer = $Panel/ScrollContainer/LabelContainer
@onready var _label_array : Array[Node]
@onready var _time : float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_position_window()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_position_window()
	# rainbow effect for mythical items
	if _quality > Item.legendary_quality_cutoff:
		var h = 0.5 * cos(_time) + 0.5
		var new_color : Color = Color.from_hsv(h, 0.7, 1.0, 1.0)
		_item_name.label_settings.font_color = new_color
	_time += delta


# Called with after adding this to scene tree. ie: add_child(this HoverInfo) then HoverInfo.update_data(corresponding Item)
func update_data(item : Item = null) -> void:
	if item != null:
		_quality = item.quality
		_quality_mult = item.quality_mult
		_item_name.text = item.item_name
		_quality_label.text = item.quality_name
		_quality_color = item.quality_color
		_item_name.label_settings.font_color = _quality_color
	
	
	
	# Item class specific actions TODO: Add more cases for any new item classes, like probably going to add active items at some point
	if item is ProjectileModifier:
		# instantiate labels TODO: the range should be how many fields there are for a modifier
		for i in range(10):
			var new_label = Label.new()
			_label_array.append(new_label)
			_label_container.add_child(new_label)
		
		
		_label_array[0].text = str(int(item.delta_dmg / _quality_mult)) + " --> " + str(item.delta_dmg)
	elif item is ProjectileSpawner:
		pass
	elif item is SpecialModifier:
		pass

func _position_window() -> void:
	var mouse_pos = get_screen_transform() * get_local_mouse_position()
	var window_offset = Vector2(23.0, 20.0)
	var pos = mouse_pos + window_offset
	var screen_rect = get_viewport_rect()
	var info_rect = get_rect()
	if mouse_pos.x + window_offset.x + info_rect.size.x > screen_rect.size.x:
		pos = Vector2(screen_rect.size.x - info_rect.size.x, clampf(mouse_pos.y + window_offset.y, 0.0, screen_rect.size.y - info_rect.size.y))
	if mouse_pos.y + window_offset.y + info_rect.size.y > screen_rect.size.y:
		pos = Vector2(clampf(mouse_pos.x + window_offset.x, 0.0, screen_rect.size.x - info_rect.size.x), screen_rect.size.y - info_rect.size.y)
	global_position = pos
