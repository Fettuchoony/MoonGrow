extends MeshInstance3D

@onready var _overworld : Node3D = $"../CurrentLevel/MainTestScene"
@onready var _underworld : Node3D = $"../CurrentLevel/Underworld"
@onready var _player_overworld_cam : Camera3D = $"../MainPlayer/CameraPivot/SpringArm3D/Camera3D"
@onready var _player_underworld_cam : Camera3D = $"../MainPlayer/PortalViewport/UnderworldCam"
#@onready var _lighting : DirectionalLight3D = $"../DirectionalLight3D"
@onready var _remote_portal_cam : RemoteTransform3D = $"../MainPlayer/CameraPivot/SpringArm3D/UnderworldRemoteTransfer"
@onready var _displaying_overworld = false
@onready var _portal_viewport : SubViewport = $"../MainPlayer/PortalViewport"
@onready var _portal_area : Area3D = $PortalArea
@onready var _exit_trigger_1 : Area3D = $ExitTrigger1
@onready var _exit_trigger_2 : Area3D = $ExitTrigger2
@onready var _on_cooldown : bool = false

@export var width : float = 5.0
@export var height : float = 5.0
@onready var _thickness : float = 0.2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_spawn_frame()
		


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	## You are in overworld looking at underworld portal
	if !_on_cooldown && _portal_area.has_overlapping_areas() && !_displaying_overworld:
		_on_cooldown = true
		get_tree().call_group("portals", "flip_portal")
		_on_cooldown = true
		var player_cam_parent = _player_overworld_cam.get_parent()
		#_player_overworld_cam.reparent(_player_underworld_cam.get_parent())
		_player_underworld_cam.reparent(player_cam_parent)
		print("portalling")
	
	## You are in underworld looking at overworld portal
	elif !_on_cooldown && _portal_area.has_overlapping_areas() && _displaying_overworld:
		_on_cooldown = true
		get_tree().call_group("portals", "flip_portal")
		var player_cam_parent = _player_underworld_cam.get_parent()
		#_player_underworld_cam.reparent(_player_overworld_cam.get_parent())
		_player_overworld_cam.reparent(player_cam_parent)
	
	if _exit_trigger_1.has_overlapping_areas() || _exit_trigger_2.has_overlapping_areas():
		print("resetting")
		if _on_cooldown:
			get_tree().call_group("portals", "flip_cameras")
		_on_cooldown = false
	#var mat = mesh.surface_get_material(0)
	##mat.set_shader_parameter("underworld_texture", portal_viewport)
	#if !_cooldown_area.has_overlapping_bodies():
		#_on_cooldown = false
	## You are in overworld looking at underworld portal
	#if !_on_cooldown && _portal_area.has_overlapping_areas() && !_displaying_overworld:
		#get_tree().call_group("portals", "flip_portal")
		#_on_cooldown = true
		#var player_cam_parent = _player_overworld_cam.get_parent()
		#_player_overworld_cam.reparent(_player_underworld_cam.get_parent())
		#_player_underworld_cam.reparent(player_cam_parent)
	## You are in underworld looking at overworld portal
	#elif !_on_cooldown && _portal_area.has_overlapping_areas() && _displaying_overworld:
		#get_tree().call_group("portals", "flip_portal")
		#_on_cooldown = true
		#var player_cam_parent = _player_underworld_cam.get_parent()
		#_player_underworld_cam.reparent(_player_overworld_cam.get_parent())
		#_player_overworld_cam.reparent(player_cam_parent)

func flip_portal() -> void:
	if _displaying_overworld:
		print("Flipping to overworld")
		_displaying_overworld = true
		set_layer_mask_value(2, false)
		set_layer_mask_value(1, true)
	elif !_displaying_overworld:
		print("Flipping to underworld")
		_displaying_overworld = false
		set_layer_mask_value(2, true)
		set_layer_mask_value(1, false)

func flip_cameras() -> void:
	if !_displaying_overworld:
		_remote_portal_cam.set_remote_node(_player_overworld_cam.get_path())
	elif _displaying_overworld:
		_remote_portal_cam.set_remote_node(_player_underworld_cam.get_path())

func _spawn_frame() -> void:
	# Create mesh instances for frame
	var top : MeshInstance3D = MeshInstance3D.new()
	var left_side : MeshInstance3D = MeshInstance3D.new()
	var right_side : MeshInstance3D = MeshInstance3D.new()
	var bottom : MeshInstance3D = MeshInstance3D.new()
	
	# Add instances to tree
	add_child(top)
	add_child(left_side)
	add_child(right_side)
	add_child(bottom)
	
	# Add meshes to instances 
	top.mesh = BoxMesh.new()
	left_side.mesh = BoxMesh.new()
	right_side.mesh = BoxMesh.new()
	bottom.mesh = BoxMesh.new()
	
	# Create actual portal mesh that the shader will act on
	var portal_mesh = BoxMesh.new()
	set_mesh(portal_mesh)
	portal_mesh.material = load("res://SceneObjs/Environmental/portal_mat.tres")
	
	# Set portal size
	portal_mesh.size = Vector3(width, height, _thickness)
	
	# Set size and pos of the frame
	top.mesh.size = Vector3(width, 0.1, _thickness + 0.1)
	left_side.mesh.size = Vector3(0.1, height, _thickness + 0.1)
	right_side.mesh.size = Vector3(0.1, height, _thickness + 0.1)
	bottom.mesh.size = Vector3(width, 0.1, _thickness + 0.1)
	top.position = Vector3(0.0, height/2.0 + 0.1, 0.0)
	left_side.position = Vector3(-width/2.0 - 0.1, 0.0, 0.0)
	right_side.position = Vector3(width/2.0 + 0.1, 0.0, 0.0)
	bottom.position = Vector3(0.0, -height/2.0 - 0.1, 0.0)
	
	# adjust portal collider
	var portal_col = _portal_area.find_child("PortalCol")
	portal_col.shape.set_size(Vector3(width, height, _thickness/2.0))
	print(portal_col.shape.size)
	
	# Init exit triggers
	var trigger = _exit_trigger_1.find_child("PortalCol")
	trigger.shape.set_size(Vector3(width, height, _thickness/2.0))
	trigger = _exit_trigger_2.find_child("PortalCol")
	trigger.shape.set_size(Vector3(width, height, _thickness/2.0))
	_exit_trigger_1.position.z += _thickness
	_exit_trigger_2.position.z -= _thickness
	
	
