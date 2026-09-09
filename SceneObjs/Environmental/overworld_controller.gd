extends Node3D

@onready var disabled : bool = false
@onready var terrain = $NavigationRegion3D/HTerrain

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	terrain.set_collision_enabled(!disabled)


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
		#data.load_data("res://TerrainData/data.hterrain")
		#terrain.update_collider()
	#print("Overworld disabled: " + str(disabled))
