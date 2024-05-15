extends Node2D

var astar = AStar2D.new()
var market_cargos = []
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
	move_to($Spaces/Space3)
	randomize()
	market_cargos.append_array(Cargos.new().deck)
	market_cargos.shuffle()
	market_ships.append_array(Ships.new().deck)
	market_ships.shuffle()
	$"%MarketCargo".setup(market_cargos[0])
	$"%MarketShip".setup(market_ships[0])
	$"%Character".setup(Characters.new().deck[0])
	$"%Player".increase_money(4)
	$"%Ship".setup(StarterShips.new().deck[0])
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
	$"%Gain2K".disabled = true
	$"%Recover".disabled = true
	start_action()

func move_to(space):
	$"%Player".current_space = space
	$"%Player".position = space.position

func start_action():
	if not planets.has($"%Player".current_space.id):
		stop_action()
	else:
		$"%Done".disabled = false
		$"%TurnIndicator".text = "Turn " + str(turn) + ", Action Step\n"
		$"%TurnIndicator".text += "Perform any number or no actions, then press Done!"
		bought = false
		skipped = false
		update_action_buttons()

func stop_action():
	$"%MarketCargo".disable_buy()
	$"%MarketCargo".disable_skip()
	$"%MarketShip".disable_buy()
	$"%MarketShip".disable_skip()
	$"%ShipCargo".disable_deliver()
	$"%ShipCargo".disable_drop()
	$"%ShipCargo2".disable_deliver()
	$"%ShipCargo2".disable_drop()
	$"%ShipCargo3".disable_deliver()
	$"%ShipCargo3".disable_drop()
	$"%Done".disabled = true
	start_encounter()

func update_action_buttons():
	$"%MarketCargo".enable_buy()
	$"%MarketCargo".enable_skip()
	$"%MarketShip".enable_buy()
	$"%MarketShip".enable_skip()
	$"%ShipCargo".enable_deliver()
	$"%ShipCargo".enable_drop()
	$"%ShipCargo2".enable_deliver()
	$"%ShipCargo2".enable_drop()
	$"%ShipCargo3".enable_deliver()
	$"%ShipCargo3".enable_drop()
	if skipped:
		$"%MarketCargo".disable_skip()
		$"%MarketShip".disable_skip()
	if bought:
		$"%MarketCargo".disable_buy()
		$"%MarketCargo".disable_skip()
		$"%MarketShip".disable_buy()
		$"%MarketShip".disable_skip()
	if $"%Player".get_money() < $"%MarketCargo".get_data().buy:
		$"%MarketCargo".disable_buy()
	if $"%Player".current_space.get_node("Label").text == $"%MarketCargo".get_to():
		$"%MarketCargo".disable_buy()
	var available_cargos = 0
	if not $"%ShipCargo".has_cargo:
		available_cargos += 1
		$"%ShipCargo".disable_drop()
	if $"%ShipCargo2".visible and not $"%ShipCargo2".has_cargo:
		available_cargos += 1
		$"%ShipCargo2".disable_drop()
	if $"%ShipCargo3".visible and not $"%ShipCargo3".has_cargo:
		available_cargos += 1
		$"%ShipCargo3".disable_drop()
	if available_cargos == 0:
		$"%MarketCargo".disable_buy()
	if $"%Player".get_money() < $"%MarketShip".get_data().buy:
		$"%MarketShip".disable_buy()
	if $"%Player".current_space.get_node("Label").text != $"%ShipCargo".get_to():
		$"%ShipCargo".disable_deliver()
	if $"%Player".current_space.get_node("Label").text != $"%ShipCargo2".get_to():
		$"%ShipCargo2".disable_deliver()
	if $"%Player".current_space.get_node("Label").text != $"%ShipCargo3".get_to():
		$"%ShipCargo3".disable_deliver()

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
			$"%PromptContainer".show()
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
							$"%FailedSell".text = "Keep Cargo -1" + faction
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
							$"%FailedSell".text = "Keep Cargo -1" + faction
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
	var result1 = 0
	for _i in range(attack1):
		var result = roll()
		if result == "hit":
			result1 += 1
		if result == "crit":
			result1 += 2
	var result2 = 0
	for _i in range(attack2):
		var result = roll()
		if result == "hit":
			result2 += 1
		if result == "crit":
			result2 += 2
	return {
		"attacker_won": result2 < result1,
		"attacker_damage": result2,
		"defender_damage": result1,
	}

func start_encounter():
	start_turn()

func start_turn():
	turn += 1
	start_planning()

func _on_space_pressed(space):
	move_to(space)
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

func _on_done_pressed():
	stop_action()

func _on_market_cargo_buy_pressed():
	$"%Player".decrease_money(market_cargos[0].buy)
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
	bought = true
	update_action_buttons()

func _on_market_cargo_skip_pressed():
	market_cargos.append(market_cargos.pop_front())
	$"%MarketCargo".setup(market_cargos[0])
	skipped = true
	update_action_buttons()

func _on_market_ship_buy_pressed():
	$"%Player".decrease_money(market_ships[0].buy)
	$"%Ship".setup(market_ships[0])
	market_ships.pop_front()
	$"%MarketShip".setup(market_ships[0])
	if $"%Ship".get_data().cargo == 2:
		$"%ShipCargo2".show()
	else:
		$"%ShipCargo2".hide()
	bought = true
	update_action_buttons()
	
func _on_market_ship_skip_pressed():
	market_ships.append(market_ships.pop_front())
	$"%MarketShip".setup(market_ships[0])
	skipped = true
	update_action_buttons()

func _on_ship_cargo_deliver_pressed():
	deliver_cargo($"%ShipCargo")
	
func _on_ship_cargo_deliver2_pressed():
	deliver_cargo($"%ShipCargo2")
	
func _on_ship_cargo_deliver3_pressed():
	deliver_cargo($"%ShipCargo3")
	
func _on_ship_cargo_drop_pressed():
	if $"%ShipCargo".get_data().has("smuggling compartment"):
		smuggling_compartment = false
		$"%ShipCargo3".hide()
		remove_cargo($"%ShipCargo")
		if $"%ShipCargo3".has_cargo:
			$"%ShipCargo".setup($"%ShipCargo3".get_data())
			remove_cargo($"%ShipCargo3")
	else:
		remove_cargo($"%ShipCargo")

func _on_ship_cargo_drop2_pressed():
	if $"%ShipCargo2".get_data().has("smuggling compartment"):
		smuggling_compartment = false
		$"%ShipCargo3".hide()
		remove_cargo($"%ShipCargo2")
		if $"%ShipCargo3".has_cargo:
			$"%ShipCargo2".setup($"%ShipCargo3".get_data())
			remove_cargo($"%ShipCargo3")
	else:
		remove_cargo($"%ShipCargo2")

func _on_ship_cargo_drop3_pressed():
	remove_cargo($"%ShipCargo3")

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
		var combat = combat($"%Ship".get_data().attack, 3)
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
	$"%PromptContainer".hide()
	stop_action()

func _on_failed_sell2_pressed():
	if $"%FailedSell2".text == "Deliver -6K":
		$"%Player".increase_fame(failed_cargo.get_data().fame)
		$"%Player".increase_money(failed_cargo.get_data().sell - 6)
		remove_cargo(failed_cargo)
	if $"%FailedSell2".text == "Drop":
		remove_cargo(failed_cargo)
	$"%PromptContainer".hide()
	stop_action()

