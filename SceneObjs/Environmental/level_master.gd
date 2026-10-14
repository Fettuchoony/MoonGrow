
extends Node3D

const MAX_PORTAL_COUNT: int = 16
const IN_OVERWORLD: int = 1
const IN_UNDERWORLD: int = 2

const FLAT_PORTAL_SHADER = preload(
    "res://Materials/flat_portal.tres"
)

@onready var _player: CharacterBody3D = $"../MainPlayer"
@onready var _overworld: Node3D = $MainTestScene
@onready var _underworld: Node3D = $Underworld

var _curr_level: Node3D
var _portals: Array[Node] = []
var _last_portal_count: int = -1


func _ready() -> void:
	_curr_level = get_child(0) as Node3D if get_child_count() > 0 else null

	_refresh_portals()
	_init_dimension_shader()
	_update_dimension_shader()


func _process(_delta: float) -> void:
	# Refresh only when the number of portals changes.
	# This detects additions/removals without querying every frame.
	var current_count := get_tree().get_nodes_in_group("portals").size()

	if current_count != _last_portal_count:
		_refresh_portals()
		_init_dimension_shader()

	_update_dimension_shader()


func _refresh_portals() -> void:
	_portals.clear()

	for node in get_tree().get_nodes_in_group("portals"):
		if is_instance_valid(node):
			_portals.append(node)
		print(node.global_position)

	_last_portal_count = _portals.size()


func load_level(level: PackedScene, global_shift: Vector3) -> void:
	if level == null:
		push_error("Load zone has no assigned target level.")
		return

	var new_level := level.instantiate() as Node3D

	if new_level == null:
		push_error("Loaded scene root must inherit Node3D.")
		return

	# Add the new level before removing the previous level.
	add_child(new_level)
	new_level.global_position = global_shift

	var previous_level := _curr_level
	_curr_level = new_level

	if is_instance_valid(previous_level):
		previous_level.queue_free()

	_init_dimension_shader()
	_refresh_portals()
	_update_dimension_shader()


func _init_dimension_shader() -> void:
	_assign_dimension_materials(_overworld, IN_OVERWORLD)
	_assign_dimension_materials(_underworld, IN_UNDERWORLD)

func _assign_dimension_materials(root: Node, dimension: int) -> void:
	for node in root.find_children("*", "MeshInstance3D", true, false):
		var mesh_instance := node as MeshInstance3D
		if mesh_instance == null:
			continue

		mesh_instance.material_override = FLAT_PORTAL_SHADER
		mesh_instance.set_instance_shader_parameter(
			"visual_layer",
			dimension
		)


func _update_dimension_shader() -> void:
	var portal_positions := PackedVector3Array()
	var portal_norms := PackedVector3Array()
	var portal_rights := PackedVector3Array()
	var portal_ups := PackedVector3Array()

	portal_positions.resize(MAX_PORTAL_COUNT)
	portal_norms.resize(MAX_PORTAL_COUNT)
	portal_rights.resize(MAX_PORTAL_COUNT)
	portal_ups.resize(MAX_PORTAL_COUNT)

	for i in range(MAX_PORTAL_COUNT):
		portal_positions[i] = Vector3.ZERO
		portal_norms[i] = Vector3.ZERO
		portal_rights[i] = Vector3.ZERO
		portal_ups[i] = Vector3.ZERO

	for i in range(mini(_portals.size(), MAX_PORTAL_COUNT)):
		var portal := _portals[i] as Node3D
		if not is_instance_valid(portal):
			continue

		# Remove scale while preserving the portal's orientation.
		var portal_basis: Basis = portal.global_basis.orthonormalized()

		portal_positions[i] = _portals[i].global_position
		portal_rights[i] = portal_basis.x
		portal_ups[i] = portal_basis.y
		portal_norms[i] = portal_basis.z

	FLAT_PORTAL_SHADER.set_shader_parameter(
		"portal_count", mini(_portals.size(), MAX_PORTAL_COUNT)
	)
	FLAT_PORTAL_SHADER.set_shader_parameter("portal_positions", portal_positions)
	FLAT_PORTAL_SHADER.set_shader_parameter("portal_norms", portal_norms)
	FLAT_PORTAL_SHADER.set_shader_parameter("portal_rights", portal_rights)
	FLAT_PORTAL_SHADER.set_shader_parameter("portal_ups", portal_ups)
	FLAT_PORTAL_SHADER.set_shader_parameter(
		"player_dimension", _get_player_dimension()
	)
	FLAT_PORTAL_SHADER.set_shader_parameter("portal_count", 1)
	FLAT_PORTAL_SHADER.set_shader_parameter("debug_portal_intersection", false)

func _get_player_dimension() -> int:
	return IN_OVERWORLD if _player.in_overworld else IN_UNDERWORLD
