# This class is now doing a lot of heavy lifting, controls its pickup/placement and spawns
class_name Item extends PanelContainer

static var HOVER_INFO_WAIT_TIME : float = 0.4

var _quality : float = 1.0
var quality_name : String = "Quality Here"
var quality_color : Color = Color.WHITE

# Control node that follows the cursor, can transfer items
@onready var _cursor_slot = get_tree().root.get_child(0).find_child("ItemHold").find_child("Augment")

# Probably poorly named, hold the actual item icon control nodes
@onready var _gui : AspectRatioContainer = $GUI

# Yellow rectangle when hovering over item with no delay
@onready var _player_gui = get_tree().root.get_child(0).find_child("PlayerGUI")
@onready var _hover : TextureRect = $GUI/Hover
@onready var _hover_info : HoverInfo
@onready var _hover_info_resource = preload("res://SceneObjs/UI/Scenes/hover_info.tscn")
@onready var _hovering_timer : float = 0

# Item is disabled for some reason, often compatibility
@onready var invalid : TextureRect = $GUI/Invalid

# If true, item is in stable spot, if not, it is being held by cursor
@onready var _stored : bool = true

# So item knows if in turret, set in move function
@onready var in_turret : bool = false

# If not in turret, array empty
@onready var near_slots

# Amount of the item available
#@onready var amt_label : Label = $GUI/Amount

# VERY IMPORTANT, this should always be set to avoid item disappearing forever
@onready var fallback_location : Control

# Set on instantiation by creator, exported for debugging purposes
@export var item_name : String

@export var slot_icon : Texture2D


# TODO: Getting rid of amount for now, making them stack uniquely
#@export var amount : int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_adjust_rect()
	add_to_group("items")
	fallback_location = get_parent()
	if fallback_location == null:
		print_debug("Orphan Item found, not allowed because no fallback location can be set")
	# gets rid of ugly panel
	#theme.panel = StyleBoxEmpty

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_hovering_func(delta)

func _hovering_func(delta : float) -> void:
	var rect = get_rect()
	rect.position = global_position
	# When hovering at all
	if rect.has_point(get_screen_transform() * get_local_mouse_position()):
		
		_hover.visible = true
		_hovering_timer += delta
	# If mouse is off
	else:
		if _hover_info != null: _hover_info.queue_free()
		_hover.visible = false
		_hovering_timer = 0.0
	
	# If mouse has been over item for required time
	if _hovering_timer > HOVER_INFO_WAIT_TIME && _hover_info == null:
		_hover_info = _hover_info_resource.instantiate()
		_player_gui.add_child(_hover_info)
		_hover_info.update_data(self)
		_hovering_timer = 0.0
	

# On input pickup or place the item
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Click") && _stored:
		fallback_location = get_parent()
		var rect = get_rect()
		rect.position = global_position
		# When clicked
		if rect.has_point(get_screen_transform() * get_local_mouse_position()):
			invalid.visible = false
			if _cursor_slot.get_child_count() > 0:
				_cursor_slot.get_child(0).move()
			move(_cursor_slot)

# Used for moving the item somewhere
func move(new_parent = fallback_location) -> void:
	if new_parent is ItemSlot:
		reparent(new_parent.find_child("Augment"))
	else:
		reparent(new_parent)
	position = Vector2.ZERO
	_stored = !_stored
	_adjust_rect()
	# Find out if this item is being put in turret so it can interact with neighbors
	if new_parent is ItemSlot && new_parent.is_turret_slot:
		in_turret = true
		# Grab the other slots in the turret
		near_slots = new_parent.get_parent().get_children()
	else:
		in_turret = false

# Item slots can request an item (taskbar or turret)
func _request_item_for_slot(slot : Control) -> void:
	if !_stored:
		move(slot)
		if slot is ItemSlot && slot.is_turret_slot:
			get_tree().call_group("turrets", "update_turret_stats")

func _adjust_rect() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	#size = Vector2(128.0, 128.0)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	position = Vector2.ZERO
	offset_bottom = 0
	offset_left = 0
	offset_right = 0
	offset_top = 0
	
