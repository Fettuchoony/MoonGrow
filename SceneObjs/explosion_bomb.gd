extends Node3D
# This script is spawned by a bomb upon detonation

static var EXPLOSION_LIFE : float = 0.2
static var EXPLOSION_GROWTH : Vector3 = Vector3(1, 1, 1)
static var SMOKE_LIFE : float = 3
static var SMOKE_GROWTH : Vector3 = Vector3(1, 1, 1)

@onready var explosion_volume : FogVolume = $ExplosionVolume
@onready var smoke_volume : FogVolume = $SmokeVolume
@onready var flash : OmniLight3D = $Flash
@onready var particles : GPUParticles3D = $GPUParticles3D
@onready var time : float = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	particles.set_one_shot(true)
	particles.restart(true)
	smoke_volume.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	time += delta
	#print_debug(time)
	if time < EXPLOSION_LIFE:
		explosion_volume.size += delta * EXPLOSION_GROWTH
		smoke_volume.size = explosion_volume.size
	elif time > EXPLOSION_LIFE and time < SMOKE_LIFE:
		flash.visible = false
		explosion_volume.visible = false
		smoke_volume.visible = true
		smoke_volume.size += delta * SMOKE_GROWTH
	else:
		queue_free()
