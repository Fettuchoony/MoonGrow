extends Control

@onready var hover = $Hover

# List of every augment type
@onready var augment_list : Array[String] = ["Simple_Dmg"]

# If player is holding the item on cursor or not
@onready var _floating : bool = false

# Set on instantiation by creator, exported for debugging purposes
@export var selected_augment : String


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_hovering_func()
	_pickup_func()

func set_augment (augment_name : String) -> bool:
	return true

func _hovering_func() -> void:
	var rect = get_rect()
	rect.position = global_position
	if rect.has_point(get_screen_transform() * get_local_mouse_position()):
		hover.visible = true
	else:
		hover.visible = false

func _pickup_func() -> void:
	var rect = get_rect()
	rect.position = global_position
	if rect.has_point(get_screen_transform() * get_local_mouse_position()) && Input.is_action_just_pressed("Click"):
		print("Augment Selected")
