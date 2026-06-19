# This class is now doing a lot of heavy lifting, controls its pickup/placement and spawns
class_name Item extends PanelContainer

@onready var _cursor_slot = get_tree().root.get_child(0).find_child("ItemHold")

@onready var _gui : AspectRatioContainer = $GUI
@onready var _hover : TextureRect = $GUI/Hover
@onready var _stored : bool = true

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
	add_to_group("items")
	fallback_location = get_parent()
	if fallback_location == null:
		print_debug("Orphan Item found, not allowed because no fallback location can be set")
	item_name = name
	# gets rid of ugly panel
	#theme.panel = StyleBoxEmpty

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_hovering_func()

func _hovering_func() -> void:
	var rect = get_rect()
	rect.position = global_position
	if rect.has_point(get_screen_transform() * get_local_mouse_position()):
		_hover.visible = true
	else:
		_hover.visible = false

# On input pickup or place the item
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Click") && _stored:
		fallback_location = get_parent()
		var rect = get_rect()
		rect.position = global_position
		# When clicked
		if rect.has_point(get_screen_transform() * get_local_mouse_position()) && get_parent().name != _cursor_slot.name:
			if _cursor_slot.get_child_count() > 0:
				_cursor_slot.get_child(0).move(get_parent())
			move(_cursor_slot)

func move(new_parent : Control) -> void:
	#if _cursor_slot.get_child_count() > 0:
		#var cursor_item : Item = _cursor_slot.get_child(0)
		#cursor_item.reparent(get_parent())
	print("moving " + name + " from parent " + get_parent().name)
	reparent(new_parent)
	print("to: " + get_parent().name)
	position = Vector2.ZERO
	_stored = !_stored

# Item slots can request an item
func _request_item_for_slot(slot : Control) -> void:
	if !_stored:
		move(slot)
