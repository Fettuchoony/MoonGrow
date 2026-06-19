extends Control
# This script only updates the GUI, does not affect gameplay

@onready var container : HBoxContainer = $HBoxContainer
@onready var health : int = 6
@onready var max_health : int = 6

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health_gui_update(health, 0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
		

# Signal from PlayerMovement that lets GUI know of change
func health_gui_update(updated_health: int, updated_max: int) -> void:
	var heart_containers : Array[Node] = container.get_children()
	var temp_health : int = updated_health
	var temp_max : int = updated_max
	for heart_container in heart_containers:
		var half : TextureRect = heart_container.get_child(0)
		var full : TextureRect = half.get_child(0)
		if temp_max > 0:
			heart_container.visible = true
		else:
			heart_container.visible = false
		if temp_health > 1:
			half.visible = true
			full.visible = true
		elif temp_health == 1:
			half.visible = true
			full.visible = false
		else:
			half.visible = false
			full.visible = false
		temp_max -= 2
		temp_health -= 2
