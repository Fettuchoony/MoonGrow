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

#TODO: make this work with multiple projectiles
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

# Runs on ready, creates the slots
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

# Invalidates/validates all slots in slots row not inclusive of given slot
func set_projectiles_in_row(slot_num : int, enabled : bool = true) -> void:
	var grid_height = perk_slot_matrix.columns
	var row = slot_num / grid_height
	var slots = perk_slot_matrix.get_children()

	# Row neighbors
	for i in range(perk_slot_matrix.columns):
		var curr_num : int = (i + (row * grid_height)) % grid_height + (row * grid_height)
		print(str(curr_num))
		if curr_num != slot_num && _turret.applied_upgrades.has(curr_num) && _turret.applied_upgrades[curr_num] is ProjectileSpawner && slots[curr_num].get_item_in_slot() != null:
			slots[curr_num].get_item_in_slot().invalid.visible = !enabled

# Invalidates/validates all slots in slots column not inclusive of given slot
func set_projectiles_in_column(slot_num : int, enabled : bool = true) -> void:
	var grid_height = perk_slot_matrix.columns
	var column = slot_num % grid_height
	var slots = perk_slot_matrix.get_children()
	
	# Columnal neighbors
	for i in range(perk_slot_matrix.columns):
		var curr_num : int = i * grid_height + column #TODO: this may be wrong idk
		if curr_num != slot_num && _turret.applied_upgrades.has(curr_num) && _turret.applied_upgrades[curr_num] is ProjectileSpawner && slots[curr_num].get_item_in_slot() != null:
			slots[curr_num].get_item_in_slot().invalid.visible = !enabled
