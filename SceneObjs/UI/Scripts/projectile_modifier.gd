class_name ProjectileModifier extends Item
# Modifies properties of projectiles, projectile is determined by the turret's Projectile augment


# Deltas: changes to the given projectile
# Additive modifiers
@export var delta_dmg : int = 0
@export var delta_firerate : float = 0.0




# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	_modify_deltas()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super(delta)

func _input(event: InputEvent) -> void:
	super(event)

# Takes a projectile and adds its deltas
func modify_proj(proj : ProjectileSpawner):
	proj.added_dmg += delta_dmg
	proj.added_firerate += delta_firerate


# Modifies the delta of the upgrade by the upgrade quality ?with some special cases?
func _modify_deltas() -> void:
	delta_dmg *= quality
	delta_firerate *= quality
