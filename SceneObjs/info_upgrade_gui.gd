extends Control

# The turret the GUI is representing
var _turret : Node3D

var _turret_name : Label 
var _dmg : Label
var _fire_rate : Label
var _tree : TextureRect

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_turret_name = $TurretName
	_dmg = $Panel/VBoxContainer/Dmg
	_fire_rate = $Panel/VBoxContainer/FireRate
	_tree = $TreeBackground


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func init(turret: Node3D) -> void:
	_turret = turret
	_turret_name.text = turret.COLLOQUIAL_NAME + str(int(Time.get_ticks_msec() / 1000.0))
	_dmg.text = "Damage: " + str(_turret.dmg)
	_fire_rate.text = "Fire Rate: " + str(_turret.firing_rate)
	
