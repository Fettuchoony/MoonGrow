extends Control
class_name TurretUpgrades

@onready var _slot_resource = preload("res://SceneObjs/UI/Scenes/item_slot.tscn")
@onready var _grid : GridContainer = $UpgradeMatrix
# Arranges slots in 2D array [column][row]
@onready var perk_slot_matrix : Array[Array]

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
	_populate_slot_array()
	_populate_slot_matrix()


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
func _populate_slot_array() -> void:
	var population_chance = _turret.turret_value
	print(_turret.turret_value)
	for i in range(pow(_grid.columns, 2)):
		var new_slot : ItemSlot = _slot_resource.instantiate()
		_grid.add_child(new_slot)
		new_slot.is_turret_slot = true
		new_slot.toggle_slot_lock()
		if randf() < population_chance:
			print("Creating slot at pop chance: " + str(population_chance) + " and index: " + str(i))
			population_chance *= _turret.turret_value
			new_slot.toggle_slot_lock()
	_grid.get_children().shuffle()
	
func _populate_slot_matrix() -> void:
	var slot_arr = _grid.get_children()
	var grid_height = _grid.columns
	for i in range(grid_height):
		var row_arr : Array[ItemSlot]
		for j in range(grid_height):
			print(slot_arr.size())
			if !slot_arr.is_empty():
				row_arr.append(slot_arr[i * grid_height + j])
		perk_slot_matrix.append(row_arr)
	
# Returns all slots in slots row inclusive of given slot
func get_projectiles_in_row(slot_num : int, range : int) -> Array[ItemSlot]:
	var grid_height = _grid.columns
	var row = slot_num / grid_height
	var column = slot_num % grid_height
	var affected_slots : Array[ItemSlot]
	
	# Row neighbors
	for i in range(2 * range + 1):
		var curr_column : int = i + column - range
		# ignore out of bounds
		if curr_column >= 0 && curr_column < grid_height:
			affected_slots.append(perk_slot_matrix[row][curr_column])
	return affected_slots
		#var curr_slot : ItemSlot = _grid.get_children()[curr_num]
		#if _turret.applied_upgrades.has(curr_num) && _turret.applied_upgrades[curr_num] is ProjectileSpawner && curr_slot != null:

# Returns all slots in slots column inclusive of given slot
func get_projectiles_in_column(slot_num : int, range : int) -> Array[ItemSlot]:
	var grid_height = _grid.columns
	var row = slot_num / grid_height
	var column = slot_num % grid_height
	var affected_slots : Array
	
	# Row neighbors
	for i in range(2 * range + 1):
		var curr_row : int = i + row - range
		# ignore out of bounds
		if curr_row >= 0 && curr_row < grid_height:
			affected_slots.append(perk_slot_matrix[curr_row][column])
	return affected_slots
		#var curr_slot : ItemSlot = _grid.get_children()[curr_num]
		#if _turret.applied_upgrades.has(curr_num) && _turret.applied_upgrades[curr_num] is ProjectileSpawner && curr_slot != null:
