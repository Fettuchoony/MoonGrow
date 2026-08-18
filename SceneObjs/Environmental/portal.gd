extends MeshInstance3D

@onready var _portal_area : Area3D = $PortalArea
@onready var _overworld : Node3D = $"../CurrentLevel/MainTestScene"
@onready var _underworld : Node3D = $"../CurrentLevel/Underworld"
@onready var _player_overworld_cam : Camera3D = $"../MainPlayer/CameraPivot/SpringArm3D/Camera3D"
@onready var _player_underworld_cam : Camera3D = $"../MainPlayer/PortalViewport/UnderworldCam"
#@onready var _lighting : DirectionalLight3D = $"../DirectionalLight3D"
@onready var _remote_portal_cam : RemoteTransform3D = $"../MainPlayer/CameraPivot/SpringArm3D/UnderworldRemoteTransfer"
@onready var _cooldown_area : Area3D = $RefractoryArea
@onready var _on_cooldown : bool = false
@onready var _displaying_overworld = false
@onready var portal_viewport : SubViewport = $"../MainPlayer/PortalViewport"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var portal
	#var players = get_tree().get_nodes_in_group("player")
	#print(players)
	#for player in players:
		#var portal_view = player.find_child("PortalViewport")
		#var mat = mesh.surface_get_material(0) as ShaderMaterial
		#print(mat)
		#mat.set_shader_parameter("underworld_texture", portal_view)
		


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	var mat = mesh.surface_get_material(0)
	#mat.set_shader_parameter("underworld_texture", portal_viewport)
	if !_cooldown_area.has_overlapping_bodies():
		_on_cooldown = false
	# You are in overworld looking at underworld portal
	if !_on_cooldown && _portal_area.has_overlapping_areas() && !_displaying_overworld:
		get_tree().call_group("portals", "flip_portal")
		_on_cooldown = true
		var player_cam_parent = _player_overworld_cam.get_parent()
		_player_overworld_cam.reparent(_player_underworld_cam.get_parent())
		_player_underworld_cam.reparent(player_cam_parent)
	# You are in underworld looking at overworld portal
	elif !_on_cooldown && _portal_area.has_overlapping_areas() && _displaying_overworld:
		get_tree().call_group("portals", "flip_portal")
		_on_cooldown = true
		var player_cam_parent = _player_underworld_cam.get_parent()
		_player_underworld_cam.reparent(_player_overworld_cam.get_parent())
		_player_overworld_cam.reparent(player_cam_parent)

func flip_portal() -> void:
	if !_displaying_overworld:
		print("Flipping to overworld")
		_displaying_overworld = true
		_remote_portal_cam.set_remote_node(_player_overworld_cam.get_path())
		set_layer_mask_value(1, false)
		set_layer_mask_value(2, true)
	elif _displaying_overworld:
		print("Flipping to underworld")
		_displaying_overworld = false
		_remote_portal_cam.set_remote_node(_player_underworld_cam.get_path())
		set_layer_mask_value(1, true)
		set_layer_mask_value(2, false)
