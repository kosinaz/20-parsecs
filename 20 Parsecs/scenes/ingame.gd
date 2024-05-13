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

func stop_planning():
	for space in $Spaces.get_children():
		space.get_node("Button").disabled = true
	$"%Work".disabled = true

func start_action():
	stop_planning()
	if not planets.has($"%Player".current_space.id):
		stop_action()
	else:
		$"%Done".disabled = false
		$"%TurnIndicator".text = "Turn " + str(turn) + ", Action Step\n"
		$"%TurnIndicator".text += "Perform any number or no actions, then press Done!"
		bought = false
		update_market_actions()
		$"%MarketCargoDiscard".disabled = false

func stop_action():
	$"%MarketCargoBuy".disabled = true
	$"%MarketCargoDiscard".disabled = true
	$"%ShipCargoSell".disabled = true
	$"%ShipCargoDiscard".disabled = true
	$"%HiddenCargoSell".disabled = true
	$"%HiddenCargoDiscard".disabled = true
	$"%Done".disabled = true
	start_encounter()

func update_market_actions():
	$"%MarketCargoBuy".disabled = bought
	if $"%Player".current_space.get_node("Label").text == $"%MarketCargo".get_to():
		$"%MarketCargoBuy".disabled = true
	if $"%ShipCargo".has_cargo and not $"%HiddenCargoContainer".visible:
		$"%MarketCargoBuy".disabled = true
	if $"%ShipCargo".has_cargo and $"%HiddenCargoContainer".visible and $"%HiddenCargo".has_cargo:
		$"%MarketCargoBuy".disabled = true
	if $"%ShipCargo".has_cargo:
		$"%ShipCargoSell".disabled = $"%Player".current_space.get_node("Label").text != $"%ShipCargo".get_to()
		$"%ShipCargoDiscard".disabled = false
		$"%HiddenCargoContainer".visible = $"%ShipCargo".get_data().has("smuggling compartment")
	else:
		$"%ShipCargoSell".disabled = true
		$"%ShipCargoDiscard".disabled = true
	if $"%HiddenCargo".has_cargo:
		$"%HiddenCargoSell".disabled = $"%Player".current_space.get_node("Label").text != $"%HiddenCargo".get_to()
		$"%HiddenCargoDiscard".disabled = false
	else:
		$"%HiddenCargoSell".disabled = true
		$"%HiddenCargoDiscard".disabled = true

func sell_cargo(cargo):
	if cargo.get_data().has("illegal"):
		var target = 3
		if $"%HiddenCargo".visible:
			target += 2
		if randi() % 8 < target:
			$"%Player".increase_fame(cargo.get_data().fame)
			$"%Player".increase_money(cargo.get_data().sell)
			remove_cargo(cargo)
		else:
			stop_action()
	else:
		$"%Player".increase_money(cargo.get_data().sell)
		if cargo.get_data().has("rep"):
			$"%Player".increase_reputation(cargo.get_data().rep)
		remove_cargo(cargo)

func remove_cargo(cargo):
	market_cargos.append(cargo.get_data())
	cargo.clear()
	update_market_actions()

func start_encounter():
	start_turn()

func start_turn():
	turn += 1
	start_planning()

func _on_space_pressed(space):
	move_to(space)
	start_action()

func _on_work_pressed():
	$"%Player".increase_money(2000)
	start_action()

func _on_done_pressed():
	stop_action()

func _on_market_cargo_buy_pressed():
	$"%Player".decrease_money(market_cargos[0].buy)
	if not $"%ShipCargo".has_cargo:
		$"%ShipCargo".setup(market_cargos[0])
	else:
		$"%HiddenCargo".setup(market_cargos[0])
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
	sell_cargo($"%ShipCargo")
	
func _on_ship_cargo_discard_pressed():
	remove_cargo($"%ShipCargo")

func _on_hidden_cargo_sell_pressed():
	sell_cargo($"%HiddenCargo")

func _on_hidden_cargo_discard_pressed():
	remove_cargo($"%HiddenCargo")
