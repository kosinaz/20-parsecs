extends Node2D
class_name Space

export var space_1 = 0
export var space_2 = 0
export var space_3 = 0
export var space_4 = 0
var _connected_spaces = []

func _ready():
	if space_1 > 0:
		_connected_spaces.append(get_parent().get_node("Space" + str(space_1)))
	if space_2 > 0:
		_connected_spaces.append(get_parent().get_node("Space" + str(space_2)))
	if space_3 > 0:
		_connected_spaces.append(get_parent().get_node("Space" + str(space_3)))
	if space_4 > 0:
		_connected_spaces.append(get_parent().get_node("Space" + str(space_4)))
	
func _draw():
	for space in _connected_spaces:
		draw_line(Vector2(), space.position - position, Color.cornflower, 2)
	draw_circle(Vector2(), 3, Color.yellow)
