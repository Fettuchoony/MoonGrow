class_name Root extends Node3D

# QUICK REFERENCE
# USE: get_tree().root.get_child(0).VARIBLE_NAME
# This will allow easy access to frequently accessed variables

@onready var entities = $CurrentLevel/MainTestScene/Objects/Entities


@onready var curr_level = $CurrentLevel/MainTestScene
