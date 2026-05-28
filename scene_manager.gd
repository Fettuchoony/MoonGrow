extends Node3D

static var LOADING_ZONES : String = "loading_masters"
static var OUT_OF_BOUNDS : Vector3 = Vector3(99999, 99999, 99999)

@onready var current_scene : Node3D
@onready var change_scene_to_file_next_frame : String = ""
@onready var mutated_scenes = {}

## Toggles whether the manager saves player progress/status and world manipulations
@export var enable_saving : bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# TODO: Fix whole game saving system, its jank rn so im just disabling it, per scene saving on switching still works
	#if enable_saving && FileAccess.file_exists("res://UserGeneratedScenes/save.tscn"):
		#var saved_scene = load("res://UserGeneratedScenes/save.tscn").instantiate()
		## Remove all children from game
		#for child in get_children():
			#child.free()
		## Replace with saved variants
		#print(saved_scene.get_children())
		#for child in saved_scene.get_children():
			#child.reparent(self) 
	var level_scenes = get_tree().get_nodes_in_group("levels")
	# Just assume the only loaded scene is indx 0
	current_scene = level_scenes[0]
	prerender()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_handle_loading()

func _handle_loading() -> void:
	# This removes the scene changing from the physics process
	if change_scene_to_file_next_frame != "":
		#print("loading triggered")
		var player = get_node("MainPlayer")
		var next_level
		print(mutated_scenes)
		print(change_scene_to_file_next_frame)
		if mutated_scenes.has(change_scene_to_file_next_frame) && enable_saving:
			print("Have mutated scene, attempting to load from disk, current scene dictionary : ")
			print(mutated_scenes)
			next_level = load(mutated_scenes[change_scene_to_file_next_frame]).instantiate()
		else:
			next_level = load("res://SceneObjs/" + change_scene_to_file_next_frame + ".tscn").instantiate()
			print("No saved scene: instantiating initial")
		print("Switching from current scene: " + current_scene.name + " to next_level: " + next_level.name)
		add_child(next_level)
		# Unload previous scene
		var scene = PackedScene.new()
		var result = scene.pack(current_scene)
		if result == OK && enable_saving:
			var error = ResourceSaver.save(scene, "res://UserGeneratedScenes/"+ current_scene.name +".tscn")
			if error != OK:
				push_error("An error occurred while saving the scene to disk.")
		mutated_scenes[current_scene.name] = "res://UserGeneratedScenes/"+ current_scene.name +".tscn"
		current_scene.free()
		# Search all loading zones for appropriate subscene
		current_scene = next_level
		for loading_zone in get_tree().get_nodes_in_group(LOADING_ZONES):
			if loading_zone.get_subscene() == player._last_subscene:
				player.global_position = loading_zone.get_node("SpawnPoint").global_position
		change_scene_to_file_next_frame = ""
		#get_tree().change_scene_to_file(change_scene_to_file_next_frame)

func save_game() -> void:
	print("Saving All...")
	var scene = PackedScene.new()
	var result = scene.pack(self)
	if result == OK && enable_saving:
		var error = ResourceSaver.save(scene, "res://UserGeneratedScenes/save.tscn")
		if error != OK:
			push_error("An error occurred while executing main save to disk.")

# Just pack this with instanced objects to preload them, idk if theres a better way
func prerender() -> void:
	pass
	var prerender_objs = [preload("res://SceneObjs/ground_loot.tscn"), preload("res://SceneObjs/test_bullet.tscn"), preload("res://SceneObjs/explosion_bomb.tscn")]
	for obj : Resource in prerender_objs:
		if is_inside_tree():
			var dummy = obj.instantiate()
			print("loading: " + dummy.name)
			add_child(dummy)
			await get_tree().process_frame
			dummy.queue_free()
