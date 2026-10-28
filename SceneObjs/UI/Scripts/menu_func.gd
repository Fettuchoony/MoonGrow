extends Control

const DEFAULT_ICON_SIZE = 32.0

@onready var inv_window : TabContainer = $MenuInv
@onready var _item_slots = $MenuInv/Inventory/HFlowContainer
@onready var current_focus_item : TextureRect
## The rects that contain the item icon
@onready var _player : CharacterBody3D = $"../MainPlayer"
@onready var _cursor_item = $"../MainPlayer/PlayerGUI/ItemHold"
@onready var _cursor_slot = $"../MainPlayer/PlayerGUI/ItemHold/Augment"

@onready var debug


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#_on_h_slider_value_changed(1.0)
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	var inv_rect = inv_window.get_rect()
	inv_rect.position = global_position
	if event.is_action_pressed("Click") && _cursor_slot.get_child_count() > 0 && inv_rect.has_point(get_screen_transform() * get_local_mouse_position()):
		get_tree().call_group("items", "_request_item_for_slot", _item_slots)
	

# Player Controller sends a signal to toggle visibility
# Player controller handles mouse unlocking 
func _on_main_player_pause_menu() -> void:
	if inv_window.visible:
		_cursor_item.visible = false
		if _cursor_item._augment_slot.get_child_count() > 0:
			_cursor_item._augment_slot.get_child(0).move()
			get_tree().call_group("turrets", "update_turret_stats")
		inv_window.visible = false
	else:
		inv_window.visible = true


## Executes all idle anims TODO: might replace with animgraph at some point?
#func _execute_idles() -> void:
	## Turrets idle is the mesh floating infront of the player, specifics managed by turret placement tscn
	#if _current_hovered_item_name.ends_with("turret"):
		#if _currently_idleing && _current_idle_obj == null:
			#var placement_location = placement_ray.get_collision_point()
			#_current_idle_obj = turret_scene.instantiate()
			#_current_idle_obj.position = placement_location
			## Find current level to place turret
			#var curr_level = get_tree().get_nodes_in_group("levels")
			#if curr_level == null:
				#print("Cannot find current level for turret placement")
			#else:
				#curr_level = curr_level[0]
			## This way, turrets are saved on changing level
			#curr_level.add_child(_current_idle_obj)
	#elif (_current_idle_obj != null && _current_idle_obj.place_mode == true):
		#_current_idle_obj.free()


func _refresh_inventory() -> void:
	# These are reasserted here because sometimes refresh is called before this script readies
	_item_slots = $MenuInv/Inventory/HFlowContainer
	_player = $"../MainPlayer"
	if _item_slots.get_children() == null:
		return
	# Add new icons
	var inv = _player._inventory
	assert(inv != null, "Fatal error: inventory not refreshable")
	for item in inv:
		if item != null:
			if item.get_parent() != null:
				item.reparent(_item_slots)
			else:
				_item_slots.add_child(item)
			#var item_icon : TextureRect = item_gui.get_node("Icon")
			#item_gui.name = item.name
			item.visible = true
			#print("item name = " + item_gui.name)
			var already_in_menu = false
			for icon in _item_slots.get_children():
				if icon.name == item.name: 
					already_in_menu = true
			# If the item is already in the inventory, just update it
			## TODO: increment item count when picking up duplicates
			if already_in_menu:
				pass
			# If the item is new to the inventory, add it
			#else:
				#_item_slots.add_child(item_gui)
			# Do not scale taskbar rects	
