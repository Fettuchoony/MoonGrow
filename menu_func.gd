extends Control


# Slot index indicated above statically
signal bind_item(target : TextureRect, slot_index : int)

# Unequip signal to player controller
signal _unbind_item(target: TextureRect)

@onready var _item_slots : Control = $TabContainer/Inventory/HFlowContainer
@onready var _current_taskbar_index : int = 0
@onready var current_focus_item : TextureRect
@onready var _taskbar_rects = $"../MainPlayer/GUI/TaskBar/HBoxContainer".get_children()
@onready var _equip_texture = preload("res://SceneObjs/equipped.tscn")
@onready var _player = $"../MainPlayer"
@onready var _current_hovered_item_name : String = ""
@onready var turret_scene = preload("res://SceneObjs/turret_placement.tscn")
@onready var placement_ray : RayCast3D = $"../MainPlayer/CameraPivot/SpringArm3D/Camera3D/PlacementRay"
@onready var _currently_idleing : bool = false
@onready var _current_idle_obj = null



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Create array of all children (items)
	init_taskbar()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_taskbar_scrolling()
	_execute_idles()
	_item_hovering_and_selection_func()
	

# Player Controller sends a signal to toggle visibility
# Player controller handles mouse unlocking 
func _on_main_player_pause_menu() -> void:
	if visible:
		visible = false
	else:
		visible = true

## Equip handler
#func _on_item_slot_gui_input(event: InputEvent, source: Control) -> void:
	#var equip : TextureRect = source.find_child("Equipped")
	## Primary and passives
	#if event.is_action_pressed("Click"):
		## Reassign curr item
		#current_focus_item = source
		## Unequip
		#if source.equipped:
			### TODO : Emit signal to player control
			#equip.visible = false
			#source.equipped = false
			##source.equipped_on_slot_num = -1
			#_unbind_item.emit(current_focus_item)
			#_currently_idleing = false
			#_current_hovered_item_name = ""
		## Skip Equip prompt if it is a passive item
		#if source.is_passive:
			## Skip idle update
			#equip.visible = true
			#source.equipped = true
			#bind_item.emit(current_focus_item, -1)
		## Equip prompt brought up if item needs assignment
		#else:
			#equip.visible = true
			#source.equipped = true
			#bind_item.emit(source)
			#_currently_idleing = true
			#_current_hovered_item_name = current_focus_item.name

# TODO: Find a way to make this use event instead of direct input?
func _taskbar_scrolling() -> void:
	if Input.is_action_just_released("ScrollDown"):
		print("scrolling down")
		# Clear equip sprite from prev index
		_taskbar_rects[_current_taskbar_index].find_child("Equipped").visible = false
		# Move index
		_current_taskbar_index -= 1
		if _current_taskbar_index < 0:
			_current_taskbar_index = 8
		# Reveal equip sprite for curr index of taskbar
		_taskbar_rects[_current_taskbar_index].find_child("Equipped").visible = true
		_currently_idleing = false
		
	if Input.is_action_just_released("ScrollUp"):
		print("scrolling up")
		_taskbar_rects[_current_taskbar_index].find_child("Equipped").visible = false
		_current_taskbar_index += 1
		if _current_taskbar_index > 8:
			_current_taskbar_index = 0
		_taskbar_rects[_current_taskbar_index].find_child("Equipped").visible = true
		_currently_idleing = false
	#_current_hovered_item_name = _player._taskbar_items[_current_taskbar_index]


## Executes all idle anims TODO: might replace with animgraph at some point?
func _execute_idles() -> void:
	# Turrets idle is the mesh floating infront of the player, specifics managed by turret placement tscn
	if _current_hovered_item_name.ends_with("turret"):
		if _currently_idleing && _current_idle_obj == null:
			var placement_location = placement_ray.get_collision_point()
			_current_idle_obj = turret_scene.instantiate()
			_current_idle_obj.position = placement_location
			# Find current level to place turret
			var curr_level = get_tree().get_nodes_in_group("levels")
			if curr_level == null:
				print("Cannot find current level for turret placement")
			else:
				curr_level = curr_level[0]
			# This way, turrets are saved on changing level
			curr_level.add_child(_current_idle_obj)
	elif (_current_idle_obj != null && _current_idle_obj.place_mode == true):
		_current_idle_obj.free()

func init_taskbar() -> void:
	_taskbar_rects[_current_taskbar_index].find_child("Equipped").visible = true

func _refresh_inventory() -> void:
	# These are reasserted here because sometimes refresh is called before this script readies
	_item_slots = $TabContainer/Inventory/HFlowContainer
	_player = $"../MainPlayer"
	if _item_slots.get_children() == null:
		return
	# Remove old icons
	for child in _item_slots.get_children():
		child.queue_free()
	# Add new icons
	var inv = _player._inventory
	if inv == null: return
	for item in inv:
		if item != null:
			var item_gui : Control = item.find_child("GUI").duplicate()
			var amount_label : Label = item_gui.get_node("Amount")
			item_gui.name = item.name
			# Update item count
			if amount_label != null:
				amount_label.text = str(item.amount)
			_item_slots.add_child(item_gui)

func _item_hovering_and_selection_func() -> void:
	# Make sure player connection good
	if _item_slots != null && _player != null:
		# Go through each item slot, these are generated on pickup_item in player script
		for slot in _item_slots.get_children():
			# Get the rect of the actual item
			var slot_icon : TextureRect =  slot.find_child("Icon")
			assert(slot_icon != null)
			var slot_rect = slot_icon.get_rect()
			# Shift rect to position so click aligns
			slot_rect.position = slot.global_position
			# Check if shifted rect is clicked, if so bind item
			if Input.is_action_just_pressed("Click") and slot_rect.has_point(get_screen_transform() * get_local_mouse_position()):
				_player._bind_item(slot)

# When GUI icons size change from the slider
func _on_h_slider_value_changed(value: float) -> void:
	# 32 is the default pixel art texture res
	var new_size : float = 32.0 * value
	for item in _item_slots.get_children():
		item.custom_minimum_size = Vector2(new_size, new_size)
		for child in item.get_children():
			child.custom_minimum_size = Vector2(new_size, new_size)
			if child.name == "Amount":
				# divide by two because we dont want it to be too big
				child.label_settings.font_size = new_size / 2
		
		print(item.scale)
	
