extends NavigationRegion3D

const HTerrain = preload("res://addons/zylann.hterrain/hterrain.gd")

@export var _terrain : HTerrain

func _on_bake_finished() -> void:
	print_debug("baked mesh")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	navigation_mesh.set_vertices(_terrain.get_data().get_all_heights())
	bake_navigation_mesh()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
