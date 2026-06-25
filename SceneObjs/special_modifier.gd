class_name SpecialModifier extends ProjectileModifier

# Special effects
@export var horizontal_scatter : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super(delta)

# Info gui calls this
func trigger_special_effect(ui : TurretUpgrades, slot_num : int) -> void:
	if horizontal_scatter: _horizontal_scatter(ui, slot_num)
	

func _horizontal_scatter(ui : TurretUpgrades, slot_num : int) -> void:
	ui.set_projectiles_in_row(slot_num, true)
