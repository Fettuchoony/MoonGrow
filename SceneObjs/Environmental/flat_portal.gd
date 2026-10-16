
extends Node3D

const IN_OVERWORLD := 1
const IN_UNDERWORLD := 2

const FLAT_PORTAL_SHADER = preload(
	"res://Materials/flat_portal.tres"
)

@export var objects_root: Node3D
@export var source_dimension: int = IN_OVERWORLD
@export var destination_dimension: int = IN_UNDERWORLD
@export var portal_half_size := Vector2(2.5, 2.5)
@export var rearm_distance := 0.25

var _source_container: Node3D
var _destination_container: Node3D
var _previous_local_position: Vector3
var _armed := true
# instance ID -> { "original": Node3D, "source": GeometryInstance3D,
#                  "destination": GeometryInstance3D }
var _transition_objects: Dictionary = {}

@onready var _player: CharacterBody3D = $"../MainPlayer"
@onready var _player_cam: Camera3D = $"../MainPlayer/CameraPivot/SpringArm3D/CurrPlayerCam/Camera3D"
@onready var _obj_detection_area : Area3D = $AOE
@onready var _nearby_bodies : Array[Node3D]
@onready var _nearby_areas : Array[Area3D]

func _ready() -> void:
	_previous_local_position = to_local(
		_player_cam.global_position
	)

	_generate_transition_copies()

	_obj_detection_area.body_entered.connect(_on_body_entered)
	_obj_detection_area.body_exited.connect(_on_body_exited)

	for body in _obj_detection_area.get_overlapping_bodies():
		if body is Node3D:
			var root := _find_transition_root(body as Node3D)
			_begin_object_transition(root)

func _on_body_entered(body: Node3D) -> void:
	var root := _find_transition_root(body)
	_begin_object_transition(root)


func _on_body_exited(body: Node3D) -> void:
	var root := _find_transition_root(body)
	var meshes: Array[GeometryInstance3D] = []
	_collect_meshes(root, meshes)

	for original in meshes:
		if not is_instance_valid(original):
			continue

		var id := original.get_instance_id()
		if not _transition_objects.has(id):
			continue

		var plane_normal := global_basis.z.normalized()
		var signed_distance := plane_normal.dot(
			original.global_position - global_position
		)

		var final_dimension := source_dimension
		if signed_distance < 0.0:
			final_dimension = destination_dimension

		_end_object_transition(id, final_dimension)

func _generate_transition_copies() -> void:
	_source_container = Node3D.new()
	_source_container.name = "PortalSourceCopies"
	get_tree().current_scene.add_child.call_deferred(_source_container)

	_destination_container = Node3D.new()
	_destination_container.name = "PortalDestinationCopies"
	get_tree().current_scene.add_child.call_deferred(_destination_container)




func _begin_object_transition(root: Node3D) -> void:
	var meshes: Array[GeometryInstance3D] = []
	_collect_meshes(root, meshes)

	for original in meshes:
		if not is_instance_valid(original):
			continue

		if not original.visible:
			continue

		var id := original.get_instance_id()

		if _transition_objects.has(id):
			continue

		var source := original.duplicate() as GeometryInstance3D
		var destination := original.duplicate() as GeometryInstance3D
		
		# DEBUG
		source.set_instance_shader_parameter("debug_copy_type", 1)
		destination.set_instance_shader_parameter("debug_copy_type", 2)

		if source == null or destination == null:
			if is_instance_valid(source):
				source.queue_free()
			if is_instance_valid(destination):
				destination.queue_free()
			continue

		source.name = original.name + "_PortalSource"
		destination.name = original.name + "_PortalDestination"

		_source_container.add_child(source)
		_destination_container.add_child(destination)

		source.global_transform = original.global_transform
		destination.global_transform = original.global_transform

		var plane_position := global_position
		var plane_normal := global_basis.z.normalized()

		_configure_copy_tree(
			source,
			source_dimension,
			1.0,
			plane_position,
			plane_normal
		)
		_configure_copy_tree(
			destination,
			destination_dimension,
			-1.0,
			plane_position,
			plane_normal
		)

		_transition_objects[id] = {
			"original": original,
			"source": source,
			"destination": destination,
			"was_visible": original.visible
		}
		
		original.set_instance_shader_parameter("is_transition_object", false)

		_set_transition_flag_recursive(source, true)
		_set_transition_flag_recursive(destination, true)
		
		original.visible = false


func _collect_meshes(
	node: Node,
	result: Array[GeometryInstance3D]
) -> void:
	if node is GeometryInstance3D:
		result.append(node as GeometryInstance3D)
		# Duplicating this node also duplicates its descendants.
		return

	for child in node.get_children():
		_collect_meshes(child, result)

func _physics_process(_delta: float) -> void:
	_update_nearby_objs()
	_sync_transition_objects()

	var current_local_position: Vector3 = to_local(
		_player_cam.global_position
	)

	if not _armed:
		if abs(current_local_position.z) >= rearm_distance:
			_armed = true

		_previous_local_position = current_local_position
		return

	var previous_z := _previous_local_position.z
	var current_z := current_local_position.z

	var crossed := (
		(previous_z > 0.0 and current_z <= 0.0)
		or
		(previous_z < 0.0 and current_z >= 0.0)
	)

	if crossed:
		var denominator := previous_z - current_z

		if abs(denominator) > 0.000001:
			var t := previous_z / denominator
			var crossing_point: Vector3 = _previous_local_position.lerp(
				current_local_position,
				t
			)

			var inside_x : bool = abs(crossing_point.x) <= portal_half_size.x
			var inside_y : bool = abs(crossing_point.y) <= portal_half_size.y

			if inside_x and inside_y:
				_switch_dimension_player()
				_armed = false

	_previous_local_position = current_local_position

func _switch_dimension_player() -> void:
	_player.in_overworld = not _player.in_overworld

	var dimension := (
		IN_OVERWORLD
		if _player.in_overworld
		else IN_UNDERWORLD
	)

	FLAT_PORTAL_SHADER.set_shader_parameter(
		"player_dimension",
		dimension
	)

	for id in _transition_objects.keys():
		var data: Dictionary = _transition_objects[id]

		var source = data["source"] as GeometryInstance3D
		var destination = data["destination"] as GeometryInstance3D

		if is_instance_valid(source):
			_set_dimension_recursive(source, source_dimension)

		if is_instance_valid(destination):
			_set_dimension_recursive(destination, destination_dimension)

func switch_dimension_obj() -> void:
	var dimension := (
		IN_OVERWORLD
		if _player.in_overworld
		else IN_UNDERWORLD
	)

	for body in _nearby_bodies:
		if not is_instance_valid(body):
			continue

		_set_dimension_recursive(body, dimension)


func _set_dimension_recursive(node: Node, dimension: int) -> void:
	if node is GeometryInstance3D:
		var mesh_instance := node as GeometryInstance3D
		mesh_instance.set_instance_shader_parameter(
			"visual_layer",
			dimension
		)

	for child in node.get_children():
		_set_dimension_recursive(child, dimension)



func _configure_copy(
	copy: GeometryInstance3D,
	dimension: int,
	side: float,
	plane_position: Vector3,
	plane_normal: Vector3
) -> void:
	copy.set_instance_shader_parameter("portal_clipping_enabled", true)
	copy.set_instance_shader_parameter("clip_plane_position", plane_position)
	copy.set_instance_shader_parameter("clip_plane_normal", plane_normal)
	copy.set_instance_shader_parameter("clip_side", side)
	copy.set_instance_shader_parameter("visual_layer", dimension)
	copy.set_instance_shader_parameter("is_transition_object", true)

func _sync_transition_objects() -> void:
	for id in _transition_objects.keys():
		var data: Dictionary = _transition_objects[id]

		var original = data["original"] as GeometryInstance3D
		var source = data["source"] as GeometryInstance3D
		var destination = data["destination"] as GeometryInstance3D

		if not is_instance_valid(original):
			continue
		if not is_instance_valid(source) or not is_instance_valid(destination):
			continue

		source.global_transform = original.global_transform
		destination.global_transform = original.global_transform

func _end_object_transition(
	id: int,
	final_dimension: int
) -> void:
	if not _transition_objects.has(id):
		return

	var data: Dictionary = _transition_objects[id]

	var original = data["original"] as GeometryInstance3D
	var source_copy = data["source"] as GeometryInstance3D
	var destination_copy = data["destination"] as GeometryInstance3D
	var was_visible: bool = data["was_visible"]

	# Restore the original mesh if it still exists.
	if is_instance_valid(original):
		original.visible = was_visible
		_set_dimension_recursive(original, final_dimension)
	print(final_dimension)

	# Remove both temporary copies.
	if is_instance_valid(source_copy):
		source_copy.queue_free()

	if is_instance_valid(destination_copy):
		destination_copy.queue_free()

	_transition_objects.erase(id)

func _update_nearby_objs() -> void:
	_nearby_bodies = _obj_detection_area.get_overlapping_bodies()
	_nearby_areas = _obj_detection_area.get_overlapping_areas()

	for body in _nearby_bodies:
		if body is Node3D:
			_begin_object_transition(body as Node3D)

func _find_transition_root(body: Node3D) -> Node3D:
	var candidate: Node = body

	while candidate != null:
		var meshes: Array[GeometryInstance3D] = []
		_collect_meshes(candidate, meshes)

		if not meshes.is_empty() and candidate is Node3D:
			return candidate as Node3D

		candidate = candidate.get_parent()

	return body

func _configure_copy_tree(
	node: Node,
	dimension: int,
	side: float,
	plane_position: Vector3,
	plane_normal: Vector3
) -> void:
	if node is GeometryInstance3D:
		_configure_copy(
			node as GeometryInstance3D,
			dimension,
			side,
			plane_position,
			plane_normal
		)

	for child in node.get_children():
		_configure_copy_tree(
			child,
			dimension,
			side,
			plane_position,
			plane_normal
		)

func _set_transition_flag_recursive(node: Node, value: bool) -> void:
	if node is GeometryInstance3D:
		(node as GeometryInstance3D).set_instance_shader_parameter(
			"is_transition_object",
			value
		)

	for child in node.get_children():
		_set_transition_flag_recursive(child, value)
