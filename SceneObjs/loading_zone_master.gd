# This script should be the parent of all loading zones and initialize them.
extends StaticBody3D

# TODO: KEEP THIS UPDATED WITH ADDED LEVELS
## Controls where the loading zone points.[br]
## Scene Index:[br]
## 0: Main test scene[br]
## 1: First level test[br]
@onready var id_to_name : Dictionary = {
	0 : "MainTestScene",
	1 : "TestLevel"
	}

@onready var loading_zone = $LoadingZone
@onready var spawn_point = $SpawnPoint

## The id for the scene, remember to set subscene
@export var scene_target : int = 0
## The subcene id in the target scene, will through error if out of bounds
@export var subscene_target : int = 0
## The subscene of THIS loader, controls where player spawns in
@export var subscene : int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Connect loading zone area signal to this loading portal
	if loading_zone.has_signal("area_entered"):
		loading_zone.area_entered.connect(_on_loading_zone_area_entered)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_loading_zone_area_entered(area: Area3D) -> void:
	var cols = area.get_overlapping_bodies()
	print(cols)
	if cols != null and !cols.is_empty():
		print(cols)
		# Set the players subscene to the target, overides old subscene
		cols[0]._last_subscene = subscene_target
		# Moves scene to new scene
		cols[0].get_parent().change_scene_to_file_next_frame = id_to_name[scene_target]
		
func get_subscene() -> int:
	return subscene
