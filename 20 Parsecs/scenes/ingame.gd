extends Node2D

var astar = AStar2D.new()
var market_cargos = []
var turn = 1
var planets = [3, 5, 9, 10, 14, 22, 28, 34, 35, 37, 42]
var planet_names = []
var bought = false

func _ready():
	for space in $Spaces.get_children():
		space.connect("pressed", self, "_on_space_pressed")
		if space.get_node("Label").text != "":
			planet_names.append(space.get_node("Label").text)
		astar.add_point(space.id, space.position)
		if space.space_1 > 0 and space.space_1 < space.id:
			astar.connect_points(space.id, space.space_1, true)
		if space.space_2 > 0 and space.space_2 < space.id:
			astar.connect_points(space.id, space.space_2, true)
		if space.space_3 > 0 and space.space_3 < space.id:
			astar.connect_points(space.id, space.space_3, true)
		if space.space_4 > 0 and space.space_4 < space.id:
			astar.connect_points(space.id, space.space_4, true)
	move_to($Spaces/Space3)
	market_cargos.append_array(Cargos.new().deck)
	randomize()
	market_cargos.shuffle()
	$"%MarketCargo".setup(market_cargos[0])
	$"%Character".setup(Characters.new().deck[0])
	$"%Player".increase_money(4000)
	$"%Ship".setup(Ships.new().deck[0])
	start_planning()
	
func _draw():
	for id in range(1, astar.get_point_count() + 1):
		for next_id in astar.get_point_connections(id):
			draw_line(astar.get_point_position(id), astar.get_point_position(next_id), Color.darkslateblue, 2)


func move_to(space):
	$"%Player".current_space = space
	$"%Player".position = space.position


func start_planning():
	$"%TurnIndicator".text = "Turn " + str(turn) + ", Planning Step\n"
	$"%TurnIndicator".text += "Move to a highlighted space or Work for 2000 credits!"
	$"%Work".disabled = false
	enable_spaces_in_range()

func enable_spaces_in_range():
	astar.set_point_disabled(13)
	for to_id in astar.get_points():
		if astar.get_id_path($"%Player".current_space.id, to_id).size() > $"%Ship".get_data().speed + 1:
			get_node("Spaces/Space" + str(to_id)).get_node("Button").disabled = true
		else:
			get_node("Spaces/Space" + str(to_id)).get_node("Button").disabled = false
	astar.set_point_disabled(13, false)
	if astar.get_id_path($"%Player".current_space.id, 13).size() > $"%Ship".get_data().speed + 1:
		get_node("Spaces/Space13/Button").disabled = true
	else:
		get_node("Spaces/Space13/Button").disabled = false

func disable_spaces():
	for space in $Spaces.get_children():
		space.get_node("Button").disabled = true

func start_action():
	$"%Done".show()
	$"%Work".disabled = true
	if not planets.has($"%Player".current_space.id):
		start_turn()
	else:
		$"%TurnIndicator".text = "Turn " + str(turn) + ", Action Step\n"
		$"%TurnIndicator".text += "Perform any number or no actions, then press Done!"
	bought = false
	update_market_actions()
	$"%MarketCargoDiscard".disabled = false

func update_market_actions():
	$"%MarketCargoBuy".disabled = bought
	if $"%Player".current_space.get_node("Label").text == $"%MarketCargo".get_to():
		$"%MarketCargoBuy".disabled = true
	if $"%ShipCargo".get_to() != "":
		$"%ShipCargoDiscard".disabled = false
		$"%MarketCargoBuy".disabled = true
		$"%ShipCargoSell".disabled = $"%Player".current_space.get_node("Label").text != $"%ShipCargo".get_to()
	else:
		$"%ShipCargoSell".disabled = true
		$"%ShipCargoDiscard".disabled = true

func start_encounter():
	start_turn()

func start_turn():
	turn += 1
	start_planning()

func _on_space_pressed(space):
	move_to(space)
	disable_spaces()
	start_action()

func _on_done_pressed():
	$"%Done".hide()
	start_encounter()

func _on_market_cargo_buy_pressed():
	$"%Player".decrease_money(market_cargos[0].buy)
	$"%ShipCargo".setup(market_cargos[0])
	market_cargos.pop_front()
	$"%MarketCargo".setup(market_cargos[0])
	bought = true
	update_market_actions()
	$"%MarketCargoDiscard".disabled = true

func _on_market_cargo_discard_pressed():
	market_cargos.append(market_cargos.pop_front())
	$"%MarketCargo".setup(market_cargos[0])
	update_market_actions()
	$"%MarketCargoDiscard".disabled = true

func _on_ship_cargo_sell_pressed():
	$"%Player".increase_money($"%ShipCargo".get_data().sell)
	print($"%ShipCargo".get_data().rep)
	$"%Player".increase_reputation($"%ShipCargo".get_data().rep)
	_on_ship_cargo_discard_pressed()
	$"%ShipCargoSell".disabled = true
	update_market_actions()
	
func _on_ship_cargo_discard_pressed():
	market_cargos.append($"%ShipCargo".get_data())
	$"%ShipCargo".clear()
	update_market_actions()

func _on_work_pressed():
	$"%Player".increase_money(2000)
	start_action()
