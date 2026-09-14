extends MeshInstance3D

@onready var _player : CharacterBody3D = $"../MainPlayer"
@onready var _overworld : Node3D = $"../CurrentLevel/MainTestScene"
@onready var _underworld : Node3D = $"../CurrentLevel/Underworld"
@onready var _main_viewport_cam_parent = _player.find_child("CurrPlayerCam")
@onready var _player_cam : Camera3D = _player.find_child("Camera3D")
#@onready var _lighting : DirectionalLight3D = $"../DirectionalLight3D"
@onready var _portal_viewport : SubViewport
@onready var _portal_cam : Camera3D
@onready var _player_in_overworld = true
@onready var _player_in_portal : bool = false
@export var width : float = 5.0
@export var height : float = 5.0
@onready var _thickness : float = 0.15
@onready var _curr_player_to_portal_norm : Vector3 = Vector3(0.0,0.0,(_player.global_position.z - global_position.z) / abs(global_position.z - _player.global_position.z))
@onready var _deactive_z : float = 1.0
# Vector describing the movement from last physics frame to current
@onready var _last_pos : Vector3 = _player.global_position
@onready var _crossed_local_z_plane : bool = false


@export var framed : bool = false
@export var edge_collision : bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_setup_camera()
	get_surface_override_material(0).set_shader_parameter("z_slice", _thickness)
	_spawn_frame()
	

func _physics_process(delta: float) -> void:
	_crossed_local_z_plane = (to_local(_last_pos).z > 0.0 && to_local(_player.global_position).z < 0.0) || (to_local(_last_pos).z < 0.0 && to_local(_player.global_position).z > 0.0)
	_last_pos = _player.global_position
	#print(_movement_vec)

#func _unhandled_input(event: InputEvent) -> void:
	#if event.is_action_pressed("Debug"):
		#var dupe = self.duplicate()
		#get_parent().add_child(dupe)
		#dupe.global_position.x += 8.0
		#dupe.global_position.z += 2.0
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	var player_pos_in_local = to_local(_player.position)
	# Compare new norm to last frames norm to dermine direction
	var new_portal_to_player_norm : Vector3 = Vector3(0.0, 0.0, player_pos_in_local.z / abs(player_pos_in_local.z))

	_curr_player_to_portal_norm = new_portal_to_player_norm
	
	# enter portal
	if !_player_in_portal && _point_in_portal_activation():
		var local_z : float = to_local(_player_cam.global_position).z
		if local_z != 0.0:
			_deactive_z = local_z
	
	
	# exit portal
	if _player_in_portal && !_point_in_portal_activation():
		print("exit portal")
		
		var local_z : float = to_local(_player_cam.global_position).z
		if local_z != 0.0:
			_deactive_z = local_z
	
	_player_in_portal = _point_in_portal_activation()
	
	# If the portal was rounded externally
	if _crossed_local_z_plane && !_player_in_portal:
		_deactive_z *= -1.0
	
	# Player just passsed through the core
	if _crossed_local_z_plane && _player_in_portal:
		_player.in_overworld = !_player.in_overworld
		get_tree().call_group("portals", "flip_portal")
		_deactive_z *= -1.0
		flip_cameras()
		_overworld.flip_collision()
		_underworld.flip_collision()
		# Flip player to colliding with underworld
		if _player.get_collision_mask_value(1):
			print("Flipping player collision to underworld")
			_player.set_collision_mask_value(1, false)
			_player.set_collision_mask_value(16, true)
		# Flip player to colliding with overworld
		elif _player.get_collision_mask_value(16):
			print("Flipping player collision to overworld")
			_player.set_collision_mask_value(1, true)
			_player.set_collision_mask_value(16, false)
		#_player_overworld_cam.reparent(_player_underworld_cam.get_parent())
	
	get_surface_override_material(0).set_shader_parameter("deactive_z", _deactive_z)
	_crossed_local_z_plane = false
	# Camera flipping
	#if player_in_front_of_core > 0.0:
		#if !_on_cooldown:
			#print("portal core hit, flipping cams")
			#flip_cameras()
			#_on_cooldown = true

# Group called so all portals are in sync
func flip_portal() -> void:
	# Flip
	print("FLIPPING")
	_player_in_overworld = !_player_in_overworld
	set_layer_mask_value(2, !_player_in_overworld)
	set_layer_mask_value(1, _player_in_overworld)



func flip_cameras() -> void:
	# switch cams
	get_tree().call_group("cameras", "update_curr_cam", _portal_cam, _player_in_overworld)
	_player_cam.reparent(_portal_viewport)
	_portal_cam.reparent(_main_viewport_cam_parent)
	_portal_cam.global_transform = _player_cam.global_transform
	var old_player_cam = _player_cam
	_player_cam = _portal_cam
	_portal_cam = old_player_cam
	_player_cam.set_cull_mask_value(1, _player_in_overworld)
	_player_cam.set_cull_mask_value(2, !_player_in_overworld)

func _spawn_frame() -> void:
	## Create actual portal mesh that the shader will act on
	#var portal_mesh = BoxMesh.new()
	#set_mesh(portal_mesh)
	##portal_mesh.surface_set_material(0, load("res://SceneObjs/Environmental/portal_mat.tres"))
	#set_surface_override_material(0, load("res://SceneObjs/Environmental/portal_mat.tres"))
	#
	#portal_mesh.set_shader_parameter("underworld_texture", portal_viewport)
	
	# Set portal size
	mesh.size = Vector3(width, height, _thickness)	
	
	# Set viewport size
	_portal_viewport.size = DisplayServer.screen_get_size()
	
	if framed:
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
		
		# Set size and pos of the frame
		top.mesh.size = Vector3(width, 0.1, _thickness + 0.1)
		left_side.mesh.size = Vector3(0.1, height, _thickness + 0.1)
		right_side.mesh.size = Vector3(0.1, height, _thickness + 0.1)
		bottom.mesh.size = Vector3(width, 0.1, _thickness + 0.1)
		top.position = Vector3(0.0, height/2.0 + 0.1, 0.0)
		left_side.position = Vector3(-width/2.0 - 0.1, 0.0, 0.0)
		right_side.position = Vector3(width/2.0 + 0.1, 0.0, 0.0)
		bottom.position = Vector3(0.0, -height/2.0 - 0.1, 0.0)
		
		# Enable on underworld layer
		top.set_layer_mask_value(2, true)
		left_side.set_layer_mask_value(2, true)
		right_side.set_layer_mask_value(2, true)
		bottom.set_layer_mask_value(2, true)
	
	# Create player colliders
	if edge_collision:
		
		var body_top : StaticBody3D = StaticBody3D.new()
		var body_left_side : StaticBody3D = StaticBody3D.new()
		var body_right_side : StaticBody3D = StaticBody3D.new()
		var body_bottom : StaticBody3D = StaticBody3D.new()
		
		var top : CollisionShape3D = CollisionShape3D.new()
		var left_side : CollisionShape3D = CollisionShape3D.new()
		var right_side : CollisionShape3D = CollisionShape3D.new()
		var bottom : CollisionShape3D = CollisionShape3D.new()
		
		body_top.add_child(top)
		body_left_side.add_child(right_side)
		body_right_side.add_child(left_side)
		body_bottom.add_child(bottom)
		
		# Add instances to tree
		add_child(body_top)
		add_child(body_left_side)
		add_child(body_right_side)
		add_child(body_bottom)
		
		top.shape = BoxShape3D.new()
		left_side.shape = BoxShape3D.new()
		right_side.shape = BoxShape3D.new()
		bottom.shape = BoxShape3D.new()
		
		# Set size and pos of the frame
		top.shape.size = Vector3(width, 0.1, _thickness + 0.1)
		left_side.shape.size = Vector3(0.1, height, _thickness + 0.1)
		right_side.shape.size = Vector3(0.1, height, _thickness + 0.1)
		bottom.shape.size = Vector3(width, 0.1, _thickness + 0.1)
		top.position = Vector3(0.0, height/2.0 + 0.1, 0.0)
		left_side.position = Vector3(-width/2.0 - 0.1, 0.0, 0.0)
		right_side.position = Vector3(width/2.0 + 0.1, 0.0, 0.0)
		bottom.position = Vector3(0.0, -height/2.0 - 0.1, 0.0)
		
		body_top.set_collision_layer_value(16, true)
		body_left_side.set_collision_layer_value(16, true)
		body_right_side.set_collision_layer_value(16, true)
		body_bottom.set_collision_layer_value(16, true)
		
# Checks if global coord is in this portal
func _point_in_portal(pos : Vector3 = _player_cam.global_position) -> bool:
	var x_aligned : bool = pos.x < global_position.x + width/2.0 && pos.x > global_position.x - width/2.0
	var y_aligned : bool = pos.y < global_position.y + height/2.0 && pos.y > global_position.y - height/2.0
	var z_aligned : bool = pos.z < global_position.z + _thickness/2.0 && pos.z > global_position.z - _thickness/2.0
	return x_aligned && y_aligned && z_aligned

# basically is the point aligned in front of the portal
func _point_in_portal_activation(pos : Vector3 = _player_cam.global_position) -> bool:
	var x_aligned : bool = pos.x < global_position.x + width/2.0 && pos.x > global_position.x - width/2.0
	var y_aligned : bool = pos.y < global_position.y + height/2.0 && pos.y > global_position.y - height/2.0
	return x_aligned && y_aligned
	
func _setup_camera() -> void:
	
	# Add viewport
	var viewport = SubViewport.new()
	viewport.size = DisplayServer.screen_get_size()
	add_child(viewport)
	
	# Add cam to viewport
	var cam = preload("res://SceneObjs/Player/camera_3d.tscn").instantiate()
	viewport.add_child(cam)
	
	# Add material to portal and init material
	set_surface_override_material(0, preload("res://SceneObjs/Environmental/portal_mat.tres"))
	var view_tex : ViewportTexture = ViewportTexture.new()
	view_tex.set_viewport_path_in_scene(viewport.get_path())
	get_surface_override_material(0).set_shader_parameter("underworld_texture", viewport.get_texture())
	
	# Assign globals
	_portal_viewport = viewport
	_portal_cam = cam
