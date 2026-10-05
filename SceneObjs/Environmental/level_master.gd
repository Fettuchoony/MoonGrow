extends Node3D

static var MAX_PORTAL_COUNT = 16
static var OVERWORLD_DIMENSIONAL_CULL_SHADER = preload("res://Materials/overworld_portal_culled.tres")
static var UNDERWORLD_DIMENSIONAL_CULL_SHADER = preload("res://Materials/underworld_portal_culled.tres")
static var FLAT_PORTAL_SHADER = preload("res://Materials/flat_portal.tres")

@onready var _curr_level : Node3D

@onready var _player : CharacterBody3D = $"../MainPlayer"
@onready var _overworld : Node3D = $MainTestScene
@onready var _underworld : Node3D = $Underworld
@onready var _portals : Array[Node] = get_tree().get_nodes_in_group("portals")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_curr_level = get_child(0)
	_init_dimension_shader()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if get_child_count() == 1:
		_curr_level = get_child(0)
	# Too expensive
	#_portals = get_tree().get_nodes_in_group("portals")
	_update_dimension_shader()

func load_level(level : PackedScene, global_shift : Vector3):
	if level == null:
		push_error("Load zone has unnasigned target level")
	if _curr_level != null:
		var prev_level = _curr_level
		_curr_level = level.instantiate()
		add_child(_curr_level)
		_curr_level.global_position = global_shift
		prev_level.queue_free()

func _init_dimension_shader() -> void:
	# Set overworld shader to all overworld children
	#for child in _overworld.find_children("*"):
	for child in find_children("*"):
		if child is MeshInstance3D:
			#child.set_surface_override_material(0, OVERWORLD_DIMENSIONAL_CULL_SHADER)
			child.set_surface_override_material(0, FLAT_PORTAL_SHADER)
	# Set underworld shader to all underworld children
	#for child in _underworld.find_children("*"):
		#if child is MeshInstance3D:
			#child.set_surface_override_material(0, UNDERWORLD_DIMENSIONAL_CULL_SHADER)
	#OVERWORLD_DIMENSIONAL_CULL_SHADER.set_shader_parameter("portal", _player.global_position)
	#UNDERWORLD_DIMENSIONAL_CULL_SHADER.set_shader_parameter("player_position", _player.global_position)


func _update_dimension_shader() -> void:
	#if _portals.size() > MAX_PORTAL_COUNT:
		#push_error("MAXIMUM PORTAL COUNT EXCEEDED FOR SHADER, ALLOCATE MORE IN PORTAL_CULLED_SHADER")
	## Update overworld shader with portal positions and dimension status
	#var portal_positions : Array[Vector3]
	## Maximum portals is set
	#portal_positions.resize(MAX_PORTAL_COUNT)
	#portal_positions.fill(Vector3.ZERO)
	#for i : int in range(_portals.size()):
		#portal_positions.set(i, _portals[i].global_position)
	#OVERWORLD_DIMENSIONAL_CULL_SHADER.set_shader_parameter("portal_count", _portals.size())
	#OVERWORLD_DIMENSIONAL_CULL_SHADER.set_shader_parameter("portal_positions", portal_positions)
	#OVERWORLD_DIMENSIONAL_CULL_SHADER.set_shader_parameter("is_dimension", _player.in_overworld)
	#
	#UNDERWORLD_DIMENSIONAL_CULL_SHADER.set_shader_parameter("portal_count", _portals.size())
	#UNDERWORLD_DIMENSIONAL_CULL_SHADER.set_shader_parameter("portal_positions", portal_positions)
	#UNDERWORLD_DIMENSIONAL_CULL_SHADER.set_shader_parameter("is_dimension", !_player.in_overworld)
	pass
