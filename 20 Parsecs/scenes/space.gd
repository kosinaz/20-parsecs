extends Node2D
class_name Space

export var space_1 = 0
export var space_2 = 0
export var space_3 = 0
export var space_4 = 0
onready var id = int(name.right(5))

func _on_button_pressed():
	get_node("../../Player").move_to(id)
