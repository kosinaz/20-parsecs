extends Node2D

onready var astar: AStar2D = get_parent().astar
var speed = 5

func move_to(id):
	position = astar.get_point_position(id)
	astar.set_point_disabled(13)
	for to_id in astar.get_points():
		if astar.get_id_path(id, to_id).size() > speed + 1:
			get_node("../Spaces/Space" + str(to_id)).get_node("Button").disabled = true
		else:
			get_node("../Spaces/Space" + str(to_id)).get_node("Button").disabled = false
	astar.set_point_disabled(13, false)
	if astar.get_id_path(id, 13).size() > speed + 1:
		get_node("../Spaces/Space13/Button").disabled = true
	else:
		get_node("../Spaces/Space13/Button").disabled = false
			

func _draw():
	draw_circle(Vector2(), 5, Color.blue)
	
