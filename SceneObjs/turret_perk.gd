#extends TurretUpgrades
#
## Turret reference is owned by parent and set by parent, ie is accessible here
#
#@onready var _perk_tree = get_parent()
#@onready var _hover = $Hover
#@onready var _equipped = $Equipped
#
#@export var selected_perk : perk_options
#
## Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#print(selected_perk)
	#tooltip_text = name
	#pass # Replace with function body.
#
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#if _turret._applied_upgrades.has(name):
		#_equipped.visible = true
	#var curr_rect = get_rect()
	## Shift rect to position so click aligns
	#curr_rect.position = global_position
	#var is_hovering = curr_rect.has_point(get_screen_transform() * get_local_mouse_position())
	#if is_hovering:
		#_hover.visible = true
		#if Input.is_action_just_pressed("Click") && _equipped.visible == false:
			#print(_turret)
			#_apply_perk()
			#_equipped.visible = true
	#else:
		#_hover.visible = false
#
#func _apply_perk() -> void:
	## TODO: Flesh out the perks of course
	#if selected_perk == perk_options.TESTPERK0:
		#_turret.dmg += 1
		#print("Trigger Perk 0")
	#if selected_perk == perk_options.TESTPERK1:
		#print("Trigger Perk 1")
	#if selected_perk == perk_options.TESTPERK2:
		#print("Trigger Perk 2")
	#_turret._applied_upgrades[name] = true
	#_perk_tree.init(_turret)
