class_name DmgParticleSpawner extends Node3D

@onready var dmg_particle = preload("res://SceneObjs/Entity/dmg_particles.tscn")

## 0.0 = no spread, 1.0 = max spread
@export_range(0.0, 1.0) var spread : float = 1.0

## 0.0 = particle does not move vertically, 5.0 = particle goes up 5 units
@export var height : Curve

@export var size_over_life : Curve

## How many seconds the partocle will exist before self-destruction
@export var lifetime : float = 1.0

### The randomness to the angles of emission, 0.0 = no spread, 0.5 = 45 degree spread, and so on...
@export var spread_percent : float = 1.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func trigger(dmg_amt : float) -> void:
	if dmg_particle.can_instantiate():
		var particle = dmg_particle.instantiate()
		particle.init(abs(dmg_amt))
		add_child(particle)
