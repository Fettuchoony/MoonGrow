class_name ItemSlot extends TextureRect

enum Item_Type {grapple, 
				sword,
				bomb,
				gunner_turret}


@onready var root : Node3D = $"../../../.."
@onready var menu : Control = $"../../.."
# Set by menu controller and nullified by player controller
@onready var bomb_scene = preload("res://SceneObjs/bomb_item2.tscn")
@onready var grapple_scene = preload("res://SceneObjs/grapple_item.tscn")
@onready var turret_scene = preload("res://SceneObjs/turret_placement.tscn")
@onready var player_ray : RayCast3D = $"../../../../MainPlayer/CameraPivot/SpringArm3D/Camera3D/PlayerRay"
@onready var placement_ray : RayCast3D = $"../../../../MainPlayer/CameraPivot/SpringArm3D/Camera3D/PlacementRay"
@onready var hover_sprite : TextureRect
@onready var equipped_sprite : TextureRect

@export var equipped_on_slot_num : int
@export var equipped : bool
@export var amount_label : Label = find_child("Label")
@export var amount : int = 10
@export var is_passive : bool
@export var is_primary : bool
@export var item_type: Item_Type = Item_Type.sword

signal item_gui_input(event: InputEvent, source: Control)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hover_sprite = find_child("Hover")
	equipped_sprite = find_child("Equipped")
	# Connect signals for binds to the MenuController and PlayerController
	connect_signals()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_on_mouse_entered()
	_on_mouse_exited()

func connect_signals() -> void:
	item_gui_input.connect(menu._on_item_slot_gui_input)
	
# Needs to work for every item
func use_item(item_name: String, location: Node3D) -> void:
	#print_debug("Using: " + item_name)
	if amount > -1:
		if(item_name == "grapple"):
			exec_grapple(location)
		elif(item_name == "bomb"):
			amount -= 1
			exec_bomb(location)
		elif(item_name == "sword"):
			exec_sword(location)
		elif(item_name == "gunner_turret"):
			amount -= 1
			exec_turret(location)
	else:
		amount = 0
	if amount_label != null:
		amount_label.text = str(amount)

func exec_bomb(location: Node3D) -> void:
	var bomb_instance = bomb_scene.instantiate()
	bomb_instance.position = location.global_position
	root.add_child(bomb_instance)
	bomb_instance.set_owner(root)
	
func exec_grapple(location: Node3D) -> void:
	var grapple_instance = grapple_scene.instantiate()
	grapple_instance.position = location.global_position
	add_child(grapple_instance)

## TODO: Sword probably getting phased out?
func exec_sword(location: Node3D) -> void:
	var enemy = player_ray.get_collider()
	if enemy != null and enemy.collision_layer == 4:
		enemy.change_health(-1)

func exec_turret(location: Node3D) -> void:
	#var placement_location = placement_ray.get_collision_point()
	#var turret_instance = turret_scene.instantiate()
	#turret_instance.position = placement_location
	## Find current level to place turret
	#var curr_level = get_tree().get_nodes_in_group("levels")
	#if curr_level == null:
		#print("Cannot find current level for turret placement")
	#else:
		#curr_level = curr_level[0]
	## This way, turrets are saved on changing level
	#curr_level.add_child(turret_instance)
	pass
	
# Signals to menu to equip
func _gui_input(event: InputEvent) -> void:
	if event.is_action("Click"):
		item_gui_input.emit(event, self)

# Toggles sprite for hovering
func _on_mouse_exited():
	if !Rect2(Vector2(), size).has_point(get_local_mouse_position()):
		hover_sprite.visible = false

# Toggles sprite for hovering
func _on_mouse_entered():
	if Rect2(Vector2(), size).has_point(get_local_mouse_position()):
		hover_sprite.visible = true
