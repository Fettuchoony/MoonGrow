class_name ItemSlot extends AspectRatioContainer

@onready var _cursor_slot = get_tree().root.get_child(0).find_child("ItemHold")
@onready var _augment_slot = $Augment
@onready var lock_background = $DeadSlot
@onready var is_turret_slot : bool = false
@onready var can_hold_projectile : bool = true


@export var _is_cursor_slot = false
@export var is_locked = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if _is_cursor_slot:
		global_position = get_screen_transform() * get_local_mouse_position()
		if _augment_slot.get_child_count() > 0:
			visible = true
		else:
			visible = false

func _input(event: InputEvent) -> void:
	if !_is_cursor_slot && !is_locked:
		var slot_rect = get_rect()
		slot_rect.position = global_position
		if event.is_action_pressed("Click") && _cursor_slot.get_child_count() > 0 && slot_rect.has_point(get_screen_transform() * get_local_mouse_position()) && _augment_slot.get_child_count() == 0 && can_hold_projectile:
			print("sending signal to all items")
			get_tree().call_group("items", "_request_item_for_slot", self)
			get_tree().call_group("turrets", "update_turret_stats")

func get_item_in_slot() -> Item:
	if _augment_slot.get_child_count() < 1:
		return null
	else:
		return _augment_slot.get_child(0)

func toggle_slot_lock() -> void:
	is_locked = !is_locked
	lock_background.visible = !lock_background.visible
