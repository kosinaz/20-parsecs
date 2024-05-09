tool
extends Node2D

func _process(_delta):
	update()

func _draw():
	for space in get_children():
		if not space is Space:
			continue
		if space.space_1 > 0:
			draw_line(space.position, get_node("Space" + str(space.space_1)).position, Color.white)
		if space.space_2 > 0:
			draw_line(space.position, get_node("Space" + str(space.space_2)).position, Color.white)
		if space.space_3 > 0:
			draw_line(space.position, get_node("Space" + str(space.space_3)).position, Color.white)
		if space.space_4 > 0:
			draw_line(space.position, get_node("Space" + str(space.space_4)).position, Color.white)
