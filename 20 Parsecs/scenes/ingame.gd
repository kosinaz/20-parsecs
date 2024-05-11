extends Node2D

var astar = AStar2D.new()
var market_cargos = []

func _ready():
	for space in $Spaces.get_children():
		astar.add_point(space.id, space.position)
		if space.space_1 > 0 and space.space_1 < space.id:
			astar.connect_points(space.id, space.space_1, true)
		if space.space_2 > 0 and space.space_2 < space.id:
			astar.connect_points(space.id, space.space_2, true)
		if space.space_3 > 0 and space.space_3 < space.id:
			astar.connect_points(space.id, space.space_3, true)
		if space.space_4 > 0 and space.space_4 < space.id:
			astar.connect_points(space.id, space.space_4, true)
	$Player.move_to(1)
	market_cargos.append_array(Cargos.new().deck)
	randomize()
	market_cargos.shuffle()
	$"%Cargo".setup(market_cargos[0])
	
func _draw():
	for id in range(1, astar.get_point_count() + 1):
		for next_id in astar.get_point_connections(id):
			draw_line(astar.get_point_position(id), astar.get_point_position(next_id), Color.darkslateblue, 2)

func _on_market_cargo_buy_pressed():
	market_cargos.pop_front()
	$"%Cargo".setup(market_cargos[0])

func _on_market_cargo_discard_pressed():
	market_cargos.append(market_cargos.pop_front())
	$"%Cargo".setup(market_cargos[0])
