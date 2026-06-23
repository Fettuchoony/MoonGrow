extends Control
class_name TurretUpgrades

@onready var _slot_resource = preload("res://SceneObjs/upgrade_slot.tscn")
@onready var perk_slot_matrix : GridContainer = $UpgradeMatrix

# The turret the GUI is representing
var _turret : Turret

var _turret_name : Label 
var _dmg : Label
var _fire_rate : Label
var _player : CharacterBody3D
var _menu : Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_turret = get_parent()
	_turret_name = $TurretName
	_dmg = $Panel/VBoxContainer/Dmg
	_fire_rate = $Panel/VBoxContainer/FireRate
	_player = get_parent().get_parent().find_child("MainPlayer")
	_populate_slots()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# Modifies base stats with upgrades and updates display
func update_info(current_proj : ProjectileSpawner) -> void:
	if current_proj != null:
		_turret = get_parent()
		_turret_name.text = _turret.COLLOQUIAL_NAME + str(int(Time.get_ticks_msec() / 1000.0))
		_dmg.text = "Damage: " + str(current_proj.get_dmg())
		_fire_rate.text = "Fire Rate: " + str(current_proj.get_firerate())
	else:
		_dmg.text = ""
		_fire_rate.text = ""

func _populate_slots() -> void:
	var population_chance = 1.0
	for i in range(pow(perk_slot_matrix.columns, 2)):
		var new_slot : ItemSlot = _slot_resource.instantiate()
		perk_slot_matrix.add_child(new_slot)
		new_slot.is_turret_slot = true
		new_slot.toggle_slot_lock()
		if randf() < population_chance:
			print("Creating slot at pop chance: " + str(population_chance) + " and index: " + str(i))
			population_chance *= _turret.turret_value
			new_slot.toggle_slot_lock()
	perk_slot_matrix.get_children().shuffle()
	
		
