class_name EnemySpawner extends Node3D

# Only spawns on trigger method call
@onready var manual_mode : bool = false

# How many enemies per sec TODO: replace with operating budget like ror2
@onready var _spawn_freq : float = 5.0

@onready var time_since_last_spawn : float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !manual_mode && _spawn_freq <= time_since_last_spawn:
		trigger()
	
	time_since_last_spawn += delta

func trigger() -> void:
	time_since_last_spawn = 0.0
	Enemy.new(get_parent(), "TestEnemy")
