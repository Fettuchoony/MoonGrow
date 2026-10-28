
extends Node3D

const MAX_PORTAL_COUNT: int = 16
const IN_OVERWORLD: int = 1
const IN_UNDERWORLD: int = 2

const FLAT_PORTAL_SHADER : ShaderMaterial = preload(
    "res://Materials/flat_portal.tres"
)

@onready var _player: CharacterBody3D = $"../MainPlayer"
@onready var _overworld: Node3D = $MainTestScene
@onready var _underworld: Node3D = $Underworld

var _curr_level: Node3D
var _portals: Array[Node] = []
var _last_portal_count: int = -1
var _portal_materials: Array[ShaderMaterial] = []


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
		if is_instance_valid(node) and node is Node3D:
			_portals.append(node)

	_last_portal_count = get_tree().get_nodes_in_group("portals").size()

	print("Master: found ", _portals.size(), " valid portals.")



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
	if root == null:
		return

	if root is MeshInstance3D:
		_set_mesh_dimension(root as MeshInstance3D, dimension)

	for node in root.find_children("*", "MeshInstance3D", true, false):
		_set_mesh_dimension(node as MeshInstance3D, dimension)

#TODO
func _assign_dimension_collisions() -> void:
	
	pass

func convert_material(
	mesh : MeshInstance3D,
	standard: StandardMaterial3D,
	shader_mat: ShaderMaterial
) -> void:
	if shader_mat != null:
		mesh.set_instance_shader_parameter(
			"albedo_color",
			standard.albedo_color
		)

		mesh.set_instance_shader_parameter(
			"albedo_texture",
			standard.albedo_texture
		)

		mesh.set_instance_shader_parameter(
			"metallic",
			standard.metallic
		)

		mesh.set_instance_shader_parameter(
			"roughness",
			standard.roughness
		)


func _set_mesh_dimension(
	mesh_instance: MeshInstance3D,
	dimension: int
) -> void:
	if not is_instance_valid(mesh_instance) or mesh_instance.mesh == null:
		return

	mesh_instance.set_meta("visual_layer", dimension)

	var surface_count := mesh_instance.mesh.get_surface_count()

	for surface_idx in range(surface_count):
		var current_surface: Material = \
			mesh_instance.get_surface_override_material(surface_idx)

		var shader_mat: ShaderMaterial

		# Reuse a surface that has already been converted.
		if (
			current_surface is ShaderMaterial
			and (current_surface as ShaderMaterial).shader
				== FLAT_PORTAL_SHADER.shader
		):
			shader_mat = current_surface as ShaderMaterial
		else:
			# Capture the original material BEFORE replacing it.
			var original_material: Material = current_surface

			# material_override takes precedence over surface materials.
			if mesh_instance.material_override != null:
				original_material = mesh_instance.material_override

			if original_material == null:
				original_material = \
					mesh_instance.mesh.surface_get_material(surface_idx)

			shader_mat = FLAT_PORTAL_SHADER.duplicate() as ShaderMaterial

			if shader_mat == null:
				continue

			_copy_material_properties(original_material, shader_mat)

			mesh_instance.set_surface_override_material(
				surface_idx,
				shader_mat
			)

		# Track each material only once.
		if not _portal_materials.has(shader_mat):
			_portal_materials.append(shader_mat)

	# Surface materials now contain the converted materials.
	mesh_instance.material_override = null

	mesh_instance.set_instance_shader_parameter("visual_layer", dimension)
	mesh_instance.set_instance_shader_parameter(
		"portal_clipping_enabled", false
	)
	mesh_instance.set_instance_shader_parameter(
		"is_transition_object", false
	)
	mesh_instance.set_instance_shader_parameter("debug_copy_type", 0)



func _copy_material_properties(
	original: Material,
	target: ShaderMaterial
) -> void:
	if original is StandardMaterial3D:
		var standard := original as StandardMaterial3D

		target.set_shader_parameter("albedo_color", standard.albedo_color)
		target.set_shader_parameter("albedo_texture", standard.albedo_texture)
		target.set_shader_parameter("metallic", standard.metallic)
		target.set_shader_parameter("roughness", standard.roughness)

	elif original is ShaderMaterial:
		# Preserve compatible parameters if the original is already shader-based.
		var original_shader := original as ShaderMaterial

		for parameter in [
			"albedo_color",
			"albedo_texture",
			"metallic",
			"roughness"
		]:
			var value = original_shader.get_shader_parameter(parameter)

			if value != null:
				target.set_shader_parameter(parameter, value)




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

	var valid_portal_count := 0

	for portal_node in _portals:
		if not is_instance_valid(portal_node):
			continue
		if portal_node.is_queued_for_deletion():
			continue
		if not portal_node is Node3D:
			continue
		if valid_portal_count >= MAX_PORTAL_COUNT:
			break

		var portal := portal_node as Node3D
		var basis := portal.global_basis.orthonormalized()

		portal_positions[valid_portal_count] = portal.global_position
		portal_rights[valid_portal_count] = basis.x
		portal_ups[valid_portal_count] = basis.y
		portal_norms[valid_portal_count] = basis.z

		valid_portal_count += 1

	var materials_to_update: Array[ShaderMaterial] = [
		FLAT_PORTAL_SHADER
	]

	for material in _portal_materials:
		if is_instance_valid(material) and not materials_to_update.has(material):
			materials_to_update.append(material)

	for material in materials_to_update:
		material.set_shader_parameter("portal_count", valid_portal_count)
		material.set_shader_parameter("portal_positions", portal_positions)
		material.set_shader_parameter("portal_norms", portal_norms)
		material.set_shader_parameter("portal_rights", portal_rights)
		material.set_shader_parameter("portal_ups", portal_ups)
		material.set_shader_parameter(
			"player_dimension", _get_player_dimension()
		)
		material.set_shader_parameter(
			"debug_portal_intersection", false
		)


func _get_player_dimension() -> int:
	return IN_OVERWORLD if _player.in_overworld else IN_UNDERWORLD
