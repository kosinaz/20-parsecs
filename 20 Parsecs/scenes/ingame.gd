extends Node2D

var astar = AStar2D.new()
var cargo_deck = Cargos.new().deck
var market_cargos = []
var gearmod_deck = Gearmods.new().deck
var market_gearmods = []
var ship_deck = Ships.new().deck
var starter_ship_deck = StarterShips.new().deck
var character_deck = Characters.new().deck
var patrol_deck = Patrols.new().deck
var market_ships = []
var turn = 1
var planets = [3, 5, 9, 10, 14, 25, 27, 31, 38, 39, 42]
var planet_names = []
var bought = false
var skipped = false
var smuggling_compartment = false
var dice = ["hit", "hit", "hit", "crit", "blank", "blank", "focus", "focus"]
var failed_cargo = null
var failed_card = 0
onready var patrols = [$"%PatrolA", $"%PatrolB", $"%PatrolC", $"%PatrolD"]
var patrol_names = ["Ahut", "Basyn", "Cimp", "Dreb"]
var reps = ["-1AR", "-1BR", "-1CR", "-1DR"]
var attacking_patrol = null
var discount = 0
var skip_encounter = false

func _ready():
	for space in $Spaces.get_children():
		space.connect("pressed", self, "_on_space_pressed")
		if space.get_node("Label").text != "":
			planet_names.append(space.get_node("Label").text)
		if space.id == 28 or space.id == 25:
			astar.add_point(space.id, space.position, 0.5)
		else:
			astar.add_point(space.id, space.position)
		if space.space_1 > 0 and space.space_1 < space.id:
			astar.connect_points(space.id, space.space_1, true)
		if space.space_2 > 0 and space.space_2 < space.id:
			astar.connect_points(space.id, space.space_2, true)
		if space.space_3 > 0 and space.space_3 < space.id:
			astar.connect_points(space.id, space.space_3, true)
		if space.space_4 > 0 and space.space_4 < space.id:
			astar.connect_points(space.id, space.space_4, true)
	move_to($"%Player", $Spaces/Space3)
	move_to($"%PatrolA", $Spaces/Space46)
	move_to($"%PatrolB", $Spaces/Space2)
	move_to($"%PatrolC", $Spaces/Space44)
	move_to($"%PatrolD", $Spaces/Space1)
	randomize()
	market_cargos.append_array(cargo_deck)
	market_cargos.shuffle()
	market_gearmods.append_array(gearmod_deck)
	market_gearmods.shuffle()
	market_ships.append_array(ship_deck)
	market_ships.shuffle()
	$"%MarketCargo".setup(market_cargos[0])
	$"%MarketGearmod".setup(market_gearmods[0])
	$"%MarketShip".setup(market_ships[0])
	$"%Character".setup(character_deck[0])
	$"%Player".increase_money(4)
	$"%Ship".setup(starter_ship_deck[0])
	start_planning()
	
func _draw():
	for id in range(1, astar.get_point_count() + 1):
		for next_id in astar.get_point_connections(id):
			draw_line(astar.get_point_position(id), astar.get_point_position(next_id), Color.darkslateblue, 2)

func start_planning():
	$"%Gain2K".disabled = false
	$"%Recover".disabled = false
	$"%TurnIndicator".text = "Turn " + str(turn) + ", Planning Step\n"
	if $"%Character".defeated or $"%Ship".defeated:
		$"%TurnIndicator".text += "You are defeated and lost 3K! Recover!"
		$"%Gain2K".disabled = true
		$"%Player".decrease_money(3)
		return
	elif $"%Character".get_damage() > 0 or $"%Ship".get_damage() > 0:
		$"%TurnIndicator".text += "Move or Gain 2K or Recover!"
	else:
		$"%TurnIndicator".text += "Move or Gain 2K!"
		$"%Recover".disabled = true
	astar.set_point_disabled(13)
	var patrol_space_ids = []
	for r in ["A", "B", "C", "D"]:
		if $"%Player".get_reputation(r) != 1:
			var id = get_node("%Patrol" + r).current_space.id
			astar.set_point_disabled(id)
			patrol_space_ids.append(id)
	for to_id in astar.get_points():
		var path = astar.get_id_path($"%Player".current_space.id, to_id)
		if path.size() > get_speed() + 1 or path.size() == 0:
			get_node("Spaces/Space" + str(to_id)).get_node("Button").disabled = true
			get_node("Spaces/Space" + str(to_id)).get_node("Label").add_color_override("font_color", Color("9a9a9a"))
			get_node("Spaces/Space" + str(to_id)).get_node("Faction").add_color_override("font_color", Color("9a9a9a"))
		else:
			get_node("Spaces/Space" + str(to_id)).get_node("Button").disabled = false
			get_node("Spaces/Space" + str(to_id)).get_node("Label").add_color_override("font_color", Color.white)
			get_node("Spaces/Space" + str(to_id)).get_node("Faction").add_color_override("font_color", Color.white)
	astar.set_point_disabled(13, false)
	var path13 = astar.get_id_path($"%Player".current_space.id, 13)
	if path13.size() > get_speed() + 1 or path13.size() == 0:
		get_node("Spaces/Space13/Button").disabled = true
		get_node("Spaces/Space" + str(13)).get_node("Label").add_color_override("font_color", Color.white)
		get_node("Spaces/Space" + str(13)).get_node("Faction").add_color_override("font_color", Color.white)
	else:
		get_node("Spaces/Space13/Button").disabled = false
		get_node("Spaces/Space" + str(13)).get_node("Label").add_color_override("font_color", Color.white)
		get_node("Spaces/Space" + str(13)).get_node("Faction").add_color_override("font_color", Color.white)
	for id in patrol_space_ids:
		astar.set_point_disabled(id, false)
		var path = astar.get_id_path($"%Player".current_space.id, id)
		if path.size() > get_speed() + 1 or path.size() == 0:
			get_node("Spaces/Space" + str(id)).get_node("Button").disabled = true
			get_node("Spaces/Space" + str(id)).get_node("Label").add_color_override("font_color", Color("9a9a9a"))
			get_node("Spaces/Space" + str(id)).get_node("Faction").add_color_override("font_color", Color("9a9a9a"))
		else:
			get_node("Spaces/Space" + str(id)).get_node("Button").disabled = false
			get_node("Spaces/Space" + str(id)).get_node("Label").add_color_override("font_color", Color.white)
			get_node("Spaces/Space" + str(id)).get_node("Faction").add_color_override("font_color", Color.white)

func stop_planning():
	for space in $Spaces.get_children():
		space.get_node("Button").disabled = true
	$"%Gain2K".disabled = true
	$"%Recover".disabled = true
	start_action()

func move_to(ship, space):
	ship.current_space = space
	ship.position = space.position

func move_patrol(patrol, step):
	var path = astar.get_id_path(patrol.current_space.id, $"%Player".current_space.id)
	if path.size() > step + 1:
		move_to(patrol, get_node("Spaces/Space" + str(path[step])))
	else:
		move_to(patrol, $"%Player".current_space)

func upgrade_patrol(patrol):
	if patrol.name.ends_with("A"):
		move_to($"%PatrolA", $Spaces/Space46)
	if patrol.name.ends_with("B"):
		move_to($"%PatrolB", $Spaces/Space2)
	if patrol.name.ends_with("C"):
		move_to($"%PatrolC", $Spaces/Space44)
	if patrol.name.ends_with("D"):
		move_to($"%PatrolD", $Spaces/Space1)
	patrol.level += 1
	patrol.data = patrol_deck[patrol.level]
	$"%Patrols".text = "Patrols:"
	for i in range(4):
		$"%Patrols".text += "\n" + patrol_names[i] + ": "
		if patrols[i].data.has("attack"):
			$"%Patrols".text += str(patrols[i].data.attack) + "S "
		if patrols[i].data.has("money"):
			$"%Patrols".text += str(patrols[i].data.money) + "K "
		if patrols[i].data.has("fame"):
			$"%Patrols".text += str(patrols[i].data.fame) + "F "
		if patrols[i].data.has("invulnerable"):
			$"%Patrols".text += "invulnerable"
		else:
			$"%Patrols".text += reps[i]

func start_action():
	$"%Finish".disabled = false
	$"%TurnIndicator".text = "Turn " + str(turn) + ", Action Step\n"
	$"%TurnIndicator".text += "Perform any number or no actions, then press Finish!"
	bought = false
	skipped = false
	update_action_buttons()

func stop_action():
	$"%MarketCargo".disable_buy()
	$"%MarketCargo".disable_skip()
	$"%MarketGearmod".disable_buy()
	$"%MarketGearmod".disable_skip()
	$"%MarketShip".disable_buy()
	$"%MarketShip".disable_skip()
	$"%ShipCargo".disable_deliver()
	$"%ShipCargo".disable_drop()
	$"%ShipCargo".disable_barter()
	$"%ShipCargo2".disable_deliver()
	$"%ShipCargo2".disable_drop()
	$"%ShipCargo2".disable_barter()
	$"%ShipCargo3".disable_deliver()
	$"%ShipCargo3".disable_drop()
	$"%ShipCargo3".disable_barter()
	$"%ShipMod".disable_drop()
	$"%ShipMod".disable_barter()
	$"%ShipMod".disable_recover()
	$"%Finish".disabled = true
	start_encounter()

func update_action_buttons():
	$"%MarketCargo".enable_buy()
	$"%MarketCargo".enable_skip()
	$"%MarketGearmod".enable_buy()
	$"%MarketGearmod".enable_skip()
	$"%MarketShip".enable_buy()
	$"%MarketShip".enable_skip()
	$"%ShipCargo".enable_deliver()
	$"%ShipCargo".enable_drop()
	$"%ShipCargo".enable_barter()
	$"%ShipCargo2".enable_deliver()
	$"%ShipCargo2".enable_drop()
	$"%ShipCargo2".enable_barter()
	$"%ShipCargo3".enable_deliver()
	$"%ShipCargo3".enable_drop()
	$"%ShipCargo3".enable_barter()
	$"%ShipMod".enable_drop()
	$"%ShipMod".enable_barter()
	$"%ShipMod".enable_recover()
	if skipped:
		$"%MarketCargo".disable_skip()
		$"%MarketGearmod".disable_skip()
		$"%MarketShip".disable_skip()
	if bought or not planets.has($"%Player".current_space.id):
		$"%MarketCargo".disable_buy()
		$"%MarketCargo".disable_skip()
		$"%MarketGearmod".disable_buy()
		$"%MarketGearmod".disable_skip()
		$"%MarketShip".disable_buy()
		$"%MarketShip".disable_skip()
		$"%ShipCargo".disable_barter()
		$"%ShipCargo2".disable_barter()
		$"%ShipCargo3".disable_barter()
		$"%ShipMod".disable_barter()
	if $"%Player".get_money() < $"%MarketCargo".get_data().buy - discount:
		$"%MarketCargo".disable_buy()
	if $"%Player".get_money() < $"%MarketGearmod".get_data().buy - discount:
		$"%MarketGearmod".disable_buy()
	if $"%Player".current_space.get_node("Label").text == $"%MarketCargo".get_to():
		$"%MarketCargo".disable_buy()
	var available_cargos = 0
	if not $"%ShipCargo".has_cargo:
		available_cargos += 1
		$"%ShipCargo".disable_drop()
		$"%ShipCargo".disable_barter()
	if $"%ShipCargo2".visible and not $"%ShipCargo2".has_cargo:
		available_cargos += 1
		$"%ShipCargo2".disable_drop()
		$"%ShipCargo2".disable_barter()
	if $"%ShipCargo3".visible and not $"%ShipCargo3".has_cargo:
		available_cargos += 1
		$"%ShipCargo3".disable_drop()
		$"%ShipCargo3".disable_barter()
	if available_cargos == 0:
		$"%MarketCargo".disable_buy()
	var available_mods = 0
	if not $"%ShipMod".has_mod:
		available_mods += 1
		$"%ShipMod".disable_drop()
		$"%ShipMod".disable_barter()
	if available_mods == 0 and $"%MarketGearmod".get_data().type == "Mod":
		$"%MarketGearmod".disable_buy()
	if $"%Ship".get_damage() == 0:
		$"%ShipMod".disable_recover()
	if $"%MarketShip".get_data().has("used"):
		if $"%Player".get_money() < 5 or $"%Ship".get_price() == 20:
			$"%MarketShip".disable_buy()
	elif $"%Player".get_money() < $"%MarketShip".get_reduced_price($"%Ship".get_price()):
		$"%MarketShip".disable_buy()
	if $"%Player".current_space.get_node("Label").text != $"%ShipCargo".get_to() or not $"%ShipCargo".has_cargo:
		$"%ShipCargo".disable_deliver()
	if $"%Player".current_space.get_node("Label").text != $"%ShipCargo2".get_to() or not  $"%ShipCargo".has_cargo:
		$"%ShipCargo2".disable_deliver()
	if $"%Player".current_space.get_node("Label").text != $"%ShipCargo3".get_to() or not  $"%ShipCargo".has_cargo:
		$"%ShipCargo3".disable_deliver()

func update_market_prices():
	discount = 0
	if $"%ShipCargo".get_node("Barter").pressed:
		discount += $"%ShipCargo".get_data().buy
	if $"%ShipCargo2".get_node("Barter").pressed:
		discount += $"%ShipCargo2".get_data().buy
	if $"%ShipCargo3".get_node("Barter").pressed:
		discount += $"%ShipCargo3".get_data().buy
	if $"%ShipMod".get_node("Barter").pressed:
		discount += $"%ShipMod".get_data().buy
	$"%MarketCargo".get_node("Buy").text = "Buy " + str(max(0, $"%MarketCargo".get_data().buy - discount)) + "K"
	$"%MarketGearmod".get_node("Buy").text = "Buy " + str(max(0, $"%MarketGearmod".get_data().buy - discount)) + "K"
	$"%MarketShip".get_node("Buy").text = "Buy " + str(max(0, $"%MarketShip".get_price() - discount - $"%Ship".get_price())) + "K"
	update_used_ship_prices()

func deliver_cargo(cargo):
	if cargo.get_data().has("illegal"):
		failed_cargo = cargo
		var result = roll()
		failed_card = randi() % 4
		if result == "hit" or (result == "blank" and smuggling_compartment):
			$"%Player".increase_fame(cargo.get_data().fame)
			$"%Player".increase_money(cargo.get_data().sell)
			remove_cargo(cargo)
		else:
			skip_encounter = true
			$"%Prompt".show()
			$"%FailedLabel".text = "Smuggling failed!\nEncounter step will be skipped!"
			$"%FailedSell".show()
			$"%FailedSell2".show()
			if result == "crit":
				if failed_card == 0:
					$"%FailedSell".text = "Deliver -1AR"
					$"%FailedSell2".text = "Keep Cargo"
				if failed_card == 1:
					$"%FailedSell".text = "Deliver -1BR"
					$"%FailedSell2".text = "Deliver -6K"
				if failed_card == 2:
					$"%FailedSell".text = "Attack 3G"
					$"%FailedSell2".text = "Drop"
				if failed_card == 3:
					$"%FailedSell".text = "Attack 3S"
					$"%FailedSell2".hide()
			elif result == "focus":
				if failed_card == 0:
					$"%FailedSell".text = "Deliver -1DR"
					$"%FailedSell2".text = "Keep Cargo"
				if failed_card == 1:
					$"%FailedSell".text = "Deliver -1AR"
					$"%FailedSell2".text = "Deliver -6K"
				if failed_card == 2:
					if skill_test("stealth"):
						$"%FailedLabel".text += "\nStealth Test passed!"
						$"%FailedSell".text = "Deliver"
						$"%FailedSell2".hide()
					else:
						$"%FailedLabel".text += "\nStealth Test failed!"
						var faction = $"%Player".current_space.faction
						if faction == "":
							$"%FailedSell".text = "Keep Cargo"
						else:
							$"%FailedSell".text = "Keep Cargo -1" + faction + "R"
						$"%FailedSell2".hide()
				if failed_card == 3:
					if skill_test("influence"):
						$"%FailedLabel".text += "\nInfluence Test passed!"
						$"%FailedSell".text = "Deliver"
						$"%FailedSell2".hide()
					else:
						$"%FailedLabel".text += "\nInfluence Test failed!"
						$"%FailedSell".text = "Keep Cargo -1CR"
						$"%FailedSell2".hide()
			elif result == "blank":
				if failed_card == 0:
					$"%FailedSell".text = "Deliver -1BR"
					$"%FailedSell2".text = "Keep Cargo"
				if failed_card == 1:
					$"%FailedSell".text = "Deliver -1DR"
					$"%FailedSell2".text = "Deliver -6K"
				if failed_card == 2:
					if skill_test("piloting"):
						$"%FailedLabel".text += "\nPiloting Test passed!"
						$"%FailedSell".text = "Deliver"
						$"%FailedSell2".hide()
					else:
						$"%FailedLabel".text += "\nPiloting Test failed!"
						var faction = $"%Player".current_space.faction
						if faction == "":
							$"%FailedSell".text = "Keep Cargo"
						else:
							$"%FailedSell".text = "Keep Cargo -1" + faction + "R"
						$"%FailedSell2".hide()
				if failed_card == 3:
					if $"%Player".cimp == 1:
						$"%FailedLabel".text += "\nYour Cimp Reputation saved you!"
						$"%FailedSell".text = "Deliver"
						$"%FailedSell2".hide()
					else:
						if skill_test("stealth"):
							$"%FailedLabel".text += "\nStealth Test passed!"
							$"%FailedSell".text = "Deliver"
							$"%FailedSell2".hide()
						else:
							$"%FailedLabel".text += "\nStealth Test failed!"
							$"%FailedSell".text = "Keep Cargo -1CR"
							$"%FailedSell2".hide()
	else:
		$"%Player".increase_money(cargo.get_data().sell)
		if cargo.get_data().has("rep"):
			$"%Player".increase_reputation(cargo.get_data().rep)
		remove_cargo(cargo)

func remove_cargo(cargo):
	market_cargos.append(cargo.get_data())
	cargo.clear()
	update_action_buttons()
	update_market_prices()

func drop_cargo(cargo):
	if cargo.get_data().has("smuggling compartment"):
		smuggling_compartment = false
		$"%ShipCargo3".hide()
		remove_cargo(cargo)
		if $"%ShipCargo3".has_cargo:
			cargo.setup($"%ShipCargo3".get_data())
			remove_cargo($"%ShipCargo3")
	else:
		remove_cargo(cargo)

func drop_mod(mod):
	market_gearmods.append(mod.get_data())
	mod.clear()
	update_action_buttons()
	update_market_prices()
	$"%Ship".update_armor()

func roll():
	return dice[randi() % 8]

func skill_test(skill):
	var results = [roll(), roll()]
	if results.has("crit"):
		return true
	if results.has("hit") and is_skilled(skill):
		return true
	if results.has("focus") and is_highly_skilled(skill):
		return true
	return false

func is_skilled(skill):
	if $"%Character".get_data().skill1 == skill:
		return true
	if $"%Character".get_data().skill2 == skill:
		return
# todo crew
	return false

func is_highly_skilled(skill):
	var count = 0
	if $"%Character".get_data().skill1 == skill:
		count += 1
	if $"%Character".get_data().skill2 == skill:
		count += 1
# todo crew
	return count > 1

func combat(attack1, attack2):
	if $"%ShipMod".get_name() == "maneuvering thrusters" and is_skilled("Tactics"):
		attack2 -= 1
	var result1 = 0
	var autoblastered = 0
	var critautoblastered = false
	for _i in range(attack1):
		var result = roll()
		if result == "hit":
			result1 += 1
		if result == "crit":
			result1 += 2
		if result == "blank" and $"%ShipMod".get_name() == "targeting computer":
			result = roll()
			if result == "hit":
				result1 += 1
			if result == "crit":
				result1 += 2
		if result == "focus" and $"%ShipMod".get_name() == "autoblaster":
			if is_skilled("Tactics"):
				if not critautoblastered:
					critautoblastered = true
					result1 += 2
			elif autoblastered < 2:
				autoblastered += 1
				result1 += 1
	var result2 = 0
	var has_hit = false
	var has_crit = false
	for _i in range(attack2):
		var result = roll()
		if result == "hit":
			result2 += 1
			has_hit = true
		if result == "crit":
			result2 += 2
			has_crit = true
	if $"%ShipMod".get_name() == "ion cannon":
		if has_crit and is_skilled("Tactics"):
			result2 -= 2
		elif has_hit:
			result2 -= 1
	return {
		"attacker_won": result2 <= result1,
		"attacker_damage": result2,
		"defender_damage": result1,
	}

func get_speed():
	var speed = $"%Ship".get_data().speed
	if $"%ShipMod".get_name() == "nav computer":
		speed += 1
	return speed

func get_ship_attack():
	var attack = $"%Ship".get_data().attack
	if $"%ShipMod".get_name() == "quad laser":
		attack += 1
	return attack

func get_character_attack():
	var attack = $"%Character".get_data().attack
#	if $"%Gear".get_name() == "quad laser":
#		attack += 1
	return attack

func show_used_ships():
	$"%UsedShipMarket".show()
	$"%Market".hide()
	$"%ShipCargo".disable_deliver()
	$"%ShipCargo2".disable_deliver()
	$"%ShipCargo3".disable_deliver()
	$"%Finish".disabled = true
	for i in range(8):
		$"%UsedShipMarket".get_child(i).hide()
	var start = $"%Ship".get_price() / 2.5
	for i in range(start, 8):
#		if ship_deck[i] == $"%Enemy".get_data():
#			continue
		var ship = $"%UsedShipMarket".get_child(i)
		ship.show()
		ship.setup(ship_deck[i])
		if ship_deck[i].buy - $"%Ship".get_price() - discount > $"%Player".money:
			ship.get_node("Buy").disabled = true
		else:
			ship.get_node("Buy").disabled = false

func update_used_ship_prices():
	for i in range(8):
		var ship = $"%UsedShipMarket".get_child(i)
		ship.get_node("Buy").text = "Buy " + str(ship_deck[i].buy - $"%Ship".get_price() - discount) + "K"
		if ship_deck[i].buy - $"%Ship".get_price() - discount > $"%Player".money:
			ship.get_node("Buy").disabled = true
		else:
			ship.get_node("Buy").disabled = false
		
func buy_used_ship(ship):
	$"%Player".decrease_money(max(0, ship.buy - discount - $"%Ship".get_price()))
	drop_barter_pool()
	$"%Ship".setup(ship)
	market_ships.erase(ship)
	market_ships.append(market_ships.pop_front())
	market_ships.shuffle()
	$"%MarketShip".setup(market_ships[0])
	$"%UsedShipMarket".hide()
	$"%Market".show()
	$"%Finish".disabled = false
	if $"%Ship".get_data().cargo == 2:
		$"%ShipCargo2".show()
	else:
		$"%ShipCargo2".hide()
	bought = true
	$"%Ship".damage(3)
	update_action_buttons()

func buy_ship(ship):
	$"%Player".decrease_money(max(0, ship.buy - discount - $"%Ship".get_price()))
	drop_barter_pool()
	$"%Ship".setup(ship)
	market_ships.pop_front()
	$"%MarketShip".setup(market_ships[0])
	if $"%Ship".get_data().cargo == 2:
		$"%ShipCargo2".show()
	else:
		$"%ShipCargo2".hide()
	bought = true
	update_action_buttons()

func drop_barter_pool():
	if $"%ShipCargo".get_node("Barter").pressed:
		drop_cargo($"%ShipCargo")
	if $"%ShipCargo2".get_node("Barter").pressed:
		drop_cargo($"%ShipCargo2")
	if $"%ShipCargo3".get_node("Barter").pressed:
		drop_cargo($"%ShipCargo3")
	if $"%ShipMod".get_node("Barter").pressed:
		drop_mod($"%ShipMod")
	discount = 0

func start_encounter():
	if skip_encounter:
		stop_encounter()
		skip_encounter = false
	else:
		$"%Explore".disabled = false
		$"%Contact".disabled = false
		$"%Attack".disabled = true
		$"%TurnIndicator".text = "Turn " + str(turn) + ", Encounter Step\n"
		for r in ["A", "B", "C", "D"]:
			var patrol = get_node("%Patrol" + r)
			if patrol.current_space == $"%Player".current_space:
				$"%Attack".disabled = false
				attacking_patrol = patrol
				if $"%Player".get_reputation(r) == -1:
					$"%Contact".disabled = true
					$"%Explore".disabled = true
		if not planets.has($"%Player".current_space.id):
			$"%Contact".disabled = true
		if $"%Contact".disabled and $"%Explore".disabled:
			$"%TurnIndicator".text += "You must Attack the hostile patrol!"
		elif $"%Contact".disabled and $"%Attack".disabled:
			$"%TurnIndicator".text += "Explore your space!"
		elif $"%Contact".disabled:
			$"%TurnIndicator".text += "Explore your space or Attack the patrol!"
		elif $"%Attack".disabled:
			$"%TurnIndicator".text += "Explore the planet or Contact someone on it!"
		else:
			$"%TurnIndicator".text += "Explore or Contact someone or Attack the patrol!"

func stop_encounter():
	$"%Explore".disabled = true
	$"%Contact".disabled = true
	$"%Attack".disabled = true
	start_turn()

func attack_patrol():
	if attacking_patrol.data.has("invulnerable"):
		$"%Alert".show()
		$"%AlertSummary".text = "You failed the combat against\nthe undefeatable patrol!"
		var spaces = astar.get_point_connections($"%Player".current_space.id)
		move_to(attacking_patrol, get_node("Spaces/Space" + str(spaces[randi() % spaces.size()])))
		attacking_patrol = null
		$"%Ship".damage(10)
	else:
		var combat = combat(get_ship_attack(), attacking_patrol.data.attack)
		$"%Ship".damage(combat.attacker_damage)
		$"%Alert".show()
		if combat.attacker_won: 
			if $"%Ship".defeated:
				$"%AlertSummary".text = "You won the combat against the patrol!\n(" + str(combat.defender_damage) + " vs " + str(combat.attacker_damage) + ")\nYou suffered too much damage.\nYou are defeated!"
			else:
				$"%AlertSummary".text = "You won the combat against the patrol!\n(" + str(combat.defender_damage) + " vs " + str(combat.attacker_damage) + ")"
			if attacking_patrol.data.has("money"):
				$"%Player".increase_money(attacking_patrol.data.money)
			if attacking_patrol.data.has("fame"):
				$"%Player".increase_fame(attacking_patrol.data.fame)
			$"%Player".decrease_reputation(attacking_patrol.name.right(6))
			upgrade_patrol(attacking_patrol)
			attacking_patrol = null
		else:
			$"%AlertSummary".text = "You failed the combat against the patrol!\n(" + str(combat.defender_damage) + " vs " + str(combat.attacker_damage) + ")"
			var spaces = astar.get_point_connections($"%Player".current_space.id)
			move_to(attacking_patrol, get_node("Spaces/Space" + str(spaces[randi() % spaces.size()])))
			attacking_patrol = null

func start_turn():
	turn += 1
	start_planning()

func _on_space_pressed(space):
	move_to($"%Player", space)
	stop_planning()

func _on_work_pressed():
	$"%Player".increase_money(2)
	stop_planning()

func _on_heal_pressed():
	$"%Character".heal()
	$"%Ship".repair()
	stop_planning()

func _on_repair_pressed():
	$"%Character".heal()
	$"%Ship".repair()
	stop_planning()

func _on_finish_pressed():
	stop_action()

func _on_market_cargo_buy_pressed():
	$"%Player".decrease_money(max(0, market_cargos[0].buy - discount))
	drop_barter_pool()
	if market_cargos[0].has("smuggling compartment"):
		smuggling_compartment = true
		$"%ShipCargo3".show()
	if not $"%ShipCargo".has_cargo:
		$"%ShipCargo".setup(market_cargos[0])
	elif $"%ShipCargo2".visible and not $"%ShipCargo2".has_cargo:
		$"%ShipCargo2".setup(market_cargos[0])
	elif $"%ShipCargo3".visible and not $"%ShipCargo3".has_cargo:
		$"%ShipCargo3".setup(market_cargos[0])
	market_cargos.pop_front()
	$"%MarketCargo".setup(market_cargos[0])
	if market_cargos[0].has("patrol"):
		move_patrol(get_node("%Patrol" + market_cargos[0].patrol), market_cargos[0].move)
	bought = true
	update_action_buttons()

func _on_market_cargo_skip_pressed():
	market_cargos.append(market_cargos.pop_front())
	$"%MarketCargo".setup(market_cargos[0])
	skipped = true
	update_action_buttons()

func _on_market_gearmod_buy_pressed():
	$"%Player".decrease_money(max(0, market_gearmods[0].buy - discount))
	drop_barter_pool()
	if market_gearmods[0].type == "Mod":
		if not $"%ShipMod".has_mod:
			$"%ShipMod".setup(market_gearmods[0])
			$"%Ship".update_armor()
	#	elif $"%ShipCargoMod".visible and not $"%ShipCargoMod".has_cargomod:
	#		$"%ShipCargoMod".setup(market_gearmods[0])
	market_gearmods.pop_front()
	$"%MarketGearmod".setup(market_gearmods[0])
	if market_gearmods[0].has("patrol"):
		move_patrol(get_node("%Patrol" + market_gearmods[0].patrol), market_gearmods[0].move)
	bought = true
	update_action_buttons()

func _on_market_gearmod_skip_pressed():
	market_gearmods.append(market_gearmods.pop_front())
	$"%MarketGearmod".setup(market_gearmods[0])
	skipped = true
	update_action_buttons()

func _on_market_ship_buy_pressed():
	if market_ships[0].has("used"):
		show_used_ships()
	else:
		buy_ship(market_ships[0])
	
func _on_market_ship_skip_pressed():
	market_ships.append(market_ships.pop_front())
	$"%MarketShip".setup(market_ships[0])
	skipped = true
	update_action_buttons()

func _on_used_ship_market_buy_pressed():
	buy_used_ship(ship_deck[0])

func _on_used_ship_market_buy2_pressed():
	buy_used_ship(ship_deck[1])

func _on_used_ship_market_buy3_pressed():
	buy_used_ship(ship_deck[2])

func _on_used_ship_market_buy4_pressed():
	buy_used_ship(ship_deck[3])

func _on_used_ship_market_buy5_pressed():
	buy_used_ship(ship_deck[4])

func _on_used_ship_market_buy6_pressed():
	buy_used_ship(ship_deck[5])

func _on_used_ship_market_buy7_pressed():
	buy_used_ship(ship_deck[6])

func _on_used_ship_market_buy8_pressed():
	buy_used_ship(ship_deck[7])

func _on_ship_cargo_deliver_pressed():
	deliver_cargo($"%ShipCargo")
	
func _on_ship_cargo_deliver2_pressed():
	deliver_cargo($"%ShipCargo2")
	
func _on_ship_cargo_deliver3_pressed():
	deliver_cargo($"%ShipCargo3")
	
func _on_ship_cargo_drop_pressed():
	drop_cargo($"%ShipCargo")

func _on_ship_cargo_drop2_pressed():
	drop_cargo($"%ShipCargo2")

func _on_ship_cargo_drop3_pressed():
	drop_cargo($"%ShipCargo3")
	
func _on_ship_mod_drop_pressed():
	drop_mod($"%ShipMod")
	
func _on_ship_cargo_barter_toggled(_pressed):
	update_market_prices()

func _on_ship_mod_recover_pressed():
	$"%Ship".repair(1)
	$"%ShipMod".disable_recover()

func _on_failed_sell_pressed():
	if $"%FailedSell".text == "Attack 3G":
		var combat = combat($"%Character".get_data().attack, 3)
		$"%Character".damage(combat.attacker_damage)
		if combat.attacker_won: 
			if $"%Character".defeated:
				$"%FailedLabel".text = "You would have won the combat,\nbut suffered too much damage.\nYou are defeated!"
				$"%FailedSell".hide()
				$"%FailedSell2".show()
				$"%FailedSell2".text = "End Turn"
				return
			else:
				$"%FailedLabel".text = "You won the combat!"
				$"%FailedSell".show()
				$"%FailedSell".text = "Deliver"
				$"%FailedSell2".hide()
				return
		else:
			$"%FailedLabel".text = "You failed the combat!"
			$"%FailedSell".hide()
			$"%FailedSell2".show()
			$"%FailedSell2".text = "End Turn"
			return
	elif $"%FailedSell".text == "Attack 3S":
		var combat = combat(get_ship_attack(), 3)
		$"%Ship".damage(combat.attacker_damage)
		if combat.attacker_won: 
			if $"%Ship".defeated:
				$"%FailedLabel".text = "You would have won the combat,\nbut suffered too much damage.\nYou are defeated!"
				$"%FailedSell".hide()
				$"%FailedSell2".show()
				$"%FailedSell2".text = "End Turn"
				return
			else:
				$"%FailedLabel".text = "You won the combat!"
				$"%FailedSell".show()
				$"%FailedSell".text = "Deliver"
				$"%FailedSell2".hide()
				return
		else:
			$"%FailedLabel".text = "You failed the combat!"
			$"%FailedSell".hide()
			$"%FailedSell2".show()
			$"%FailedSell2".text = "End Turn"
			return
	elif $"%FailedSell".text == "Keep Cargo -1AR":
		$"%Player".decrease_reputation("A")
	elif $"%FailedSell".text == "Keep Cargo -1BR":
		$"%Player".decrease_reputation("B")
	elif $"%FailedSell".text == "Keep Cargo -1CR":
		$"%Player".decrease_reputation("C")
	elif $"%FailedSell".text != "Keep Cargo":
		if $"%FailedSell".text == "Deliver -1AR":
			$"%Player".decrease_reputation("A")
		if $"%FailedSell".text == "Deliver -1BR":
			$"%Player".decrease_reputation("B")
		if $"%FailedSell".text == "Deliver -1DR":
			$"%Player".decrease_reputation("D")
		$"%Player".increase_fame(failed_cargo.get_data().fame)
		$"%Player".increase_money(failed_cargo.get_data().sell)
		remove_cargo(failed_cargo)
	$"%Prompt".hide()
	stop_action()

func _on_failed_sell2_pressed():
	if $"%FailedSell2".text == "Deliver -6K":
		$"%Player".increase_fame(failed_cargo.get_data().fame)
		$"%Player".increase_money(failed_cargo.get_data().sell - 6)
		remove_cargo(failed_cargo)
	if $"%FailedSell2".text == "Drop":
		remove_cargo(failed_cargo)
	$"%Prompt".hide()
	stop_action()

func _on_alert_button_pressed():
	$"%Alert".hide()
	stop_encounter()

func _on_attack_pressed():
	attack_patrol()

func _on_explore_pressed():
	stop_encounter()

func _on_contact_pressed():
	stop_encounter()
