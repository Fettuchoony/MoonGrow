class_name Augment extends AspectRatioContainer

@onready var hover = $Hover

# If player is holding the item on cursor or not
@onready var _floating : bool = false
@onready var _in_turret : bool = false

# Amount of the item available
@onready var amount : int
@onready var amt_label : Label = $Amount

# Set on instantiation by creator, exported for debugging purposes
@export var item_name : String



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	item_name = name


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_hovering_func()
	_pickup_func()
	if amount <= 0:
		queue_free()

func _hovering_func() -> void:
	var rect = get_rect()
	rect.position = global_position
	if rect.has_point(get_screen_transform() * get_local_mouse_position()):
		hover.visible = true
	else:
		hover.visible = false

func _pickup_func() -> void:
	pass

func _input(event: InputEvent) -> void:
	var rect = get_rect()
	rect.position = global_position
	#if rect.has_point(get_screen_transform() * get_local_mouse_position()) && Input.is_action_just_pressed("Click"):
	if rect.has_point(get_screen_transform() * get_local_mouse_position()) && event.is_action_pressed("Click") && !_floating && !_in_turret:
		print("augment decrement")
		amount -= 1
		amt_label.text = str(amount)
