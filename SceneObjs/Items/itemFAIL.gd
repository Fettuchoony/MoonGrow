#class_name Item extends Node3D
#
## Item type
#enum ItemType {
	#RESOURCE,
	#EQUIPMENT,
	#BUILDABLE
#}
#
## Directories created on init
#var _data_3d : Node3D
#var _data_2d : Node2D
#var _GUI : AspectRatioContainer
## True if the object exists in 3d space and not just as 2d data ie. is "spawned in"
#var _exists : bool
## True if object is on ground
#var _is_dropped : bool
#
### ONREADY
#
#
#
#### EXPORT
#
## Set on instantiation by creator, exported for debugging purposes
#@export_category("Quality Strengths (Base * Mult)")
#@export var common_quality_mult : float = 1.0
#@export var uncommon_quality_mult : float = 1.2
#@export var rare_quality_mult : float = 1.4
#@export var very_rare_quality_mult : float = 1.6
#@export var legendary_quality_mult : float = 1.8
#@export var mythic_quality_mult : float = 2.0
#
#@export_category("Quality Bounds (0.0 - 1.0)")
#const common_quality_cutoff : float = 0.4
#const uncommon_quality_cutoff : float = 0.625
#const rare_quality_cutoff : float = 0.775
#const very_rare_quality_cutoff : float = 0.875
#const legendary_quality_cutoff : float = 0.95
#const mythic_quality_cutoff : float = 1.0
#
#
## Constructor for an item
#func _init() -> void:
	## Initialize 2d and 3d index
	#_data_3d = Node3D.new()
	#_data_3d.name = "3dData"
	#_data_2d = Node2D.new()
	#_data_2d.name = "2dData"
	#add_child(_data_3d)
	#add_child(_data_2d)
	#
	## Add GUI
	#_GUI = load("res://SceneObjs/UI/Scenes/item_gui.tscn").instantiate()
	#add_child(_GUI)
	#
#
#
## Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#pass # Replace with function body.
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass
	#
### On input pickup or place the item
#func _input(event: InputEvent) -> void:
	#if event.is_action_pressed("Click") && !_is_dropped && !_exists && is_visible_in_tree():
		#fallback_location = get_parent()
		#var rect = get_rect()
		#rect.position = global_position
		## When clicked
		#if rect.has_point(get_screen_transform() * get_local_mouse_position()):
			#invalid.visible = false
			#augmented.visible = false
			#if _cursor_slot.get_child_count() > 0:
				#_cursor_slot.get_child(0).move()
			#move(_cursor_slot)
