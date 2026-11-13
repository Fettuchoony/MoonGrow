class_name EnemySpawner extends Node3D

@export var enemy : String

## Only spawns on trigger method call
@export var manual_mode : bool = false

## How many enemies per sec TODO: replace with operating budget like ror2
@export var _spawn_freq : float = 5.0

@onready var time_since_last_spawn : float = 0.0

@onready var _entities = get_tree().root.get_child(0).entities

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !manual_mode && _spawn_freq <= time_since_last_spawn:
		if _entities == null: _entities = get_tree().root.get_child(0).entities
		trigger()
	
	time_since_last_spawn += delta

func trigger() -> void:
	if _entities == null:
		push_error("Cannot find entity node for spawning of " + enemy + " defaulting to parent of spawner")
		_entities = get_parent()
	var path = "res://SceneObjs/Entity/Enemies/" + enemy + ".tscn"
	var spawned_enemy = load(path).instantiate()
	print(spawned_enemy)
	time_since_last_spawn = 0.0
	_entities.add_child(spawned_enemy)
	spawned_enemy.global_position = global_position
