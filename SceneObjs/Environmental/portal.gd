extends MeshInstance3D

@onready var _main_viewport_cam_parent = $"../MainPlayer/CameraPivot/SpringArm3D"
@onready var _portal_viewport_cam_parent = $"../MainPlayer/PortalViewport"
@onready var _player_overworld_cam : Camera3D = $"../MainPlayer/CameraPivot/SpringArm3D/Camera3D"
@onready var _player_underworld_cam : Camera3D = $"../MainPlayer/PortalViewport/UnderworldCam"
#@onready var _lighting : DirectionalLight3D = $"../DirectionalLight3D"
@onready var _remote_portal_cam : RemoteTransform3D = $"../MainPlayer/CameraPivot/SpringArm3D/UnderworldRemoteTransfer"
@onready var _portal_displaying_overworld = false
@onready var _main_cam_in_overworld = true
@onready var _player_in_portal : bool = false
@onready var _on_cooldown : bool = false
@onready var _portal_area : Area3D = find_child("PortalArea")
@onready var _portal_core : Area3D = find_child("PortalCoreArea")
@export var width : float = 5.0
@export var height : float = 5.0
@onready var _thickness : float = 2.0
@onready var _player : CharacterBody3D = $"../MainPlayer"
@onready var _player_entry_point : Vector3 = Vector3.ONE
@onready var _curr_player_to_portal_norm : Vector3 = Vector3.FORWARD

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_spawn_frame()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	var player_pos_in_local = to_local(_player.position)
	# Compare new norm to last frames norm to dermine direction
	var new_portal_to_player_norm : Vector3 = Vector3(0.0, 0.0, player_pos_in_local.z / abs(player_pos_in_local.z))
	var player_passed_center : bool = false
	# norm has flipped, ie player crossed core
	if new_portal_to_player_norm != _curr_player_to_portal_norm:
		player_passed_center = true
	_curr_player_to_portal_norm = new_portal_to_player_norm
	
	
	
	# Player just passsed through the core
	if _portal_area.has_overlapping_areas():
		_player_in_portal = true
		if player_passed_center:
			get_tree().call_group("portals", "flip_portal")
			#_player_overworld_cam.reparent(_player_underworld_cam.get_parent())
			if _main_cam_in_overworld:
				_main_cam_in_overworld = false
				_player_overworld_cam.reparent(_portal_viewport_cam_parent)
				_player_underworld_cam.reparent(_main_viewport_cam_parent)
			else: 
				_main_cam_in_overworld = true
				_player_overworld_cam.reparent(_main_viewport_cam_parent)
				_player_underworld_cam.reparent(_portal_viewport_cam_parent)
	
	# outside portal
	if !_portal_area.has_overlapping_areas() && _player_in_portal:
		flip_cameras()
		_player_in_portal = false

		

	# Camera flipping
	#if player_in_front_of_core > 0.0:
		#if !_on_cooldown:
			#print("portal core hit, flipping cams")
			#flip_cameras()
			#_on_cooldown = true

func flip_portal() -> void:
	# Overworld -> Underworld
	if _portal_displaying_overworld:
		print_debug("Flipping portal to displaying underworld")
		_portal_displaying_overworld = false
		set_layer_mask_value(2, false)
		set_layer_mask_value(1, true)
		# Underworld -> Overworld
	elif !_portal_displaying_overworld:
		print_debug("Flipping portal to displaying overworld")
		_portal_displaying_overworld = true
		set_layer_mask_value(2, true)
		set_layer_mask_value(1, false)

func flip_cameras() -> void:
	# In overworld looking at underworld portal
	if !_main_cam_in_overworld:
		print_debug("Flipping portal cam to " + str(_player.find_child("Camera3D").get_path()))
		_remote_portal_cam.set_remote_node(_player.find_child("Camera3D").get_path())
		_main_cam_in_overworld = false
	# In underworld looking at overworld portal
	elif _main_cam_in_overworld:
		print_debug("Flipping portal cam to " + str(_player.find_child("UnderworldCam").get_path()))
		_remote_portal_cam.set_remote_node(_player.find_child("UnderworldCam").get_path())
		_main_cam_in_overworld = true

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
	
	top.set_layer_mask_value(2, true)
	left_side.set_layer_mask_value(2, true)
	right_side.set_layer_mask_value(2, true)
	bottom.set_layer_mask_value(2, true)
	
	# adjust portal area collider
	var portal_col = _portal_area.find_child("PortalCol")
	portal_col.shape.set_size(Vector3(width, height, _thickness))
	print(portal_col.shape.size)

	
	
	
