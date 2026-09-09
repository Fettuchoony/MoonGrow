extends Node3D

@onready var disabled : bool = true
@onready var terrain = $NavigationRegion3D/HTerrain

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func flip_collision() -> void:
	disabled = !disabled
	for child in get_children(true):
		if child is CollisionShape3D:
			child.set_deferred("disabled", disabled)
	#terrain.set_collision_enabled(!disabled)
	#var data = terrain.get_data()
	#if !disabled:
		#data.load_data("res://TerrainData/Underworld/data.hterrain")
		#terrain.update_collider()
	#print("Underworld disabled: " + str(disabled))
