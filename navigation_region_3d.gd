extends Node3D

var navigation_mesh: NavigationMesh
var source_geometry : NavigationMeshSourceGeometryData3D
var callback_parsing : Callable
var callback_baking : Callable
var region_rid: RID
var terrain
var t_data
var t_collider

func _ready() -> void:
	navigation_mesh = NavigationMesh.new()
	navigation_mesh.agent_radius = 0.5
	source_geometry = NavigationMeshSourceGeometryData3D.new()
	callback_parsing = on_parsing_done
	callback_baking = on_baking_done
	region_rid = NavigationServer3D.region_create()

	# Enable the region and set it to the default navigation map.
	NavigationServer3D.region_set_enabled(region_rid, true)
	NavigationServer3D.region_set_map(region_rid, get_world_3d().get_navigation_map())

	# Some mega-nodes like GridMap are often not ready on the first frame.
	# Also the parsing needs to happen on the main-thread.
	# So do a deferred call to avoid common parsing issues.
	parse_source_geometry.call_deferred()

func parse_source_geometry() -> void:
	source_geometry.clear()
	var root_node: Node3D = self

	# Parse the geometry from all mesh child nodes of the root node by default.
	NavigationServer3D.parse_source_geometry_data(
		navigation_mesh,
		source_geometry,
		root_node,
		callback_parsing
	)

func on_parsing_done() -> void:
	# Bake the navigation mesh on a thread with the source geometry data.
	NavigationServer3D.bake_from_source_geometry_data_async(
		navigation_mesh,
		source_geometry,
		callback_baking
	)

func on_baking_done() -> void:
	# Update the region with the updated navigation mesh.
	NavigationServer3D.region_set_navigation_mesh(region_rid, navigation_mesh)
