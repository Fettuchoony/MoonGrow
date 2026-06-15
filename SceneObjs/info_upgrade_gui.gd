extends Control
class_name TurretUpgrades

@onready var _perk_slots : Array[Node] = $UpgradeMatrix.get_children()

# The turret the GUI is representing
var _turret : Node3D

var _turret_name : Label 
var _dmg : Label
var _fire_rate : Label
var _player : CharacterBody3D
var _menu : Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_turret_name = $TurretName
	_dmg = $Panel/VBoxContainer/Dmg
	_fire_rate = $Panel/VBoxContainer/FireRate
	_player = get_parent().get_parent().find_child("MainPlayer")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# Modifies base stats with upgrades and updates display
func update_info(current_proj : ProjectileSpawner) -> void:
	_turret = get_parent()
	_turret_name.text = _turret.COLLOQUIAL_NAME + str(int(Time.get_ticks_msec() / 1000.0))
	_dmg.text = "Damage: " + str(current_proj.get_dmg())
	_fire_rate.text = "Fire Rate: " + str(current_proj.get_firerate())
	
