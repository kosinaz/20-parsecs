extends Node2D

var astar = AStar2D.new()
var market_cargos = []
var turn = 1
var planets = [3, 5, 9, 10, 14, 22, 28, 34, 35, 37, 42]
var planet_names = []
var bought = false
var dice = ["hit", "hit", "hit", "crit", "blank", "blank", "focus", "focus"]
var fake_dice = ["crit", "crit", "crit", "crit", "crit", "crit", "crit", "crit"]
var failed_cargo = null
var failed_card = 0

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
	if $"%Character".defeated:
		$"%TurnIndicator".text += "You are defeated! Heal yourself!"
		$"%Heal".disabled = false
		return
	elif $"%Character".get_damage() > 0:
		$"%TurnIndicator".text += "Move or Work for 2000 credits or Heal yourself!"
		$"%Heal".disabled = false
	else:
		$"%TurnIndicator".text += "Move or Work for 2000 credits!"
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
	$"%Heal".disabled = true
	start_action()

func start_action():
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
		failed_cargo = cargo
		var result = roll()
		failed_card = randi() % 3
		if result == "hit" or (result == "blank" and $"%HiddenCargoContainer".visible):
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
					$"%FailedSell".text = "Sell Cargo (-1 Ahut)"
					$"%FailedSell2".text = "Keep Cargo"
				if failed_card == 1:
					$"%FailedSell".text = "Sell Cargo (-1 Bsyn)"
					$"%FailedSell2".text = "Sell Cargo (-6000)"
				if failed_card == 2:
					$"%FailedSell".text = "Sell Cargo (Ground Combat vs 3 Attack)"
					$"%FailedSell2".text = "Discard Cargo"
			elif result == "focus":
				if failed_card == 0:
					$"%FailedSell".text = "Sell Cargo (-1 Dreb)"
					$"%FailedSell2".text = "Keep Cargo"
				if failed_card == 1:
					$"%FailedSell".text = "Sell Cargo (-1 Ahut)"
					$"%FailedSell2".text = "Sell Cargo (-6000)"
				if failed_card == 2:
					if skill_test("stealth"):
						$"%FailedLabel".text += "\nStealth Test passed!"
						$"%FailedSell".text = "Sell Cargo"
						$"%FailedSell2".hide()
					else:
						$"%FailedLabel".text += "\nStealth Test failed!"
						var faction = $"%Player".current_space.faction
						if faction == "":
							$"%FailedSell".text = "Keep Cargo"
						else:
							$"%FailedSell".text = "Keep Cargo (-1 " + faction + ")"
						$"%FailedSell2".hide()
			elif result == "blank":
				if failed_card == 0:
					$"%FailedSell".text = "Sell Cargo (-1 Bsyn)"
					$"%FailedSell2".text = "Keep Cargo"
				if failed_card == 1:
					$"%FailedSell".text = "Sell Cargo (-1 Dreb)"
					$"%FailedSell2".text = "Sell Cargo (-6000)"
				if failed_card == 2:
					if skill_test("piloting"):
						$"%FailedLabel".text += "\nPiloting Test passed!"
						$"%FailedSell".text = "Sell Cargo"
						$"%FailedSell2".hide()
					else:
						$"%FailedLabel".text += "\nPiloting Test failed!"
						var faction = $"%Player".current_space.faction
						if faction == "":
							$"%FailedSell".text = "Keep Cargo"
						else:
							$"%FailedSell".text = "Keep Cargo (-1 " + faction + ")"
						$"%FailedSell2".hide()
	else:
		$"%Player".increase_money(cargo.get_data().sell)
		if cargo.get_data().has("rep"):
			$"%Player".increase_reputation(cargo.get_data().rep)
		remove_cargo(cargo)

func remove_cargo(cargo):
	market_cargos.append(cargo.get_data())
	cargo.clear()
	update_market_actions()

func roll():
	return dice[randi() % 8]
	
func fake_roll():
	return fake_dice[randi() % 8]

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

func ground_combat(attack1, attack2):
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
	$"%Player".increase_money(2000)
	stop_planning()

func _on_heal_pressed():
	$"%Character".heal()
	stop_planning()

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

func _on_failed_sell_pressed():
	if $"%FailedSell".text == "Sell Cargo (Ground Combat vs 3 Attack)":
		var combat = ground_combat($"%Character".get_data().attack, 3)
		$"%Character".damage(combat.attacker_damage)
		if combat.attacker_won: 
			if $"%Character".defeated:
				$"%FailedLabel".text = "You would have won the combat,\nbut suffered too much damage.\nYou are defeated!"
				$"%FailedSell".hide()
				$"%FailedSell2".text = "End turn"
				return
			else:
				$"%FailedLabel".text = "You won the combat!"
				$"%FailedSell".text = "Sell Cargo"
				$"%FailedSell2".hide()
				return
		else:
			$"%FailedLabel".text = "You failed the combat!"
			$"%FailedSell".hide()
			$"%FailedSell2".text = "End turn"
			return
	elif $"%FailedSell".text == "Keep Cargo (-1 Ahut)":
		$"%Player".decrease_reputation("Ahut")
	elif $"%FailedSell".text == "Keep Cargo (-1 Bsyn)":
		$"%Player".decrease_reputation("Bsyn")
	elif $"%FailedSell".text != "Keep Cargo":
		if $"%FailedSell".text == "Sell Cargo (-1 Ahut)":
			$"%Player".decrease_reputation("Ahut")
		if $"%FailedSell".text == "Sell Cargo (-1 Bsyn)":
			$"%Player".decrease_reputation("Bsyn")
		if $"%FailedSell".text == "Sell Cargo (-1 Dreb)":
			$"%Player".decrease_reputation("Dreb")
		$"%Player".increase_fame(failed_cargo.get_data().fame)
		$"%Player".increase_money(failed_cargo.get_data().sell)
		remove_cargo(failed_cargo)
	$"%PromptContainer".hide()
	stop_action()

func _on_failed_sell2_pressed():
	if $"%FailedSell2".text == "Sell Cargo (-6000)":
		$"%Player".increase_fame(failed_cargo.get_data().fame)
		$"%Player".increase_money(failed_cargo.get_data().sell - 6000)
		remove_cargo(failed_cargo)
	if $"%FailedSell2".text == "Discard Cargo":
		remove_cargo(failed_cargo)
	$"%PromptContainer".hide()
	stop_action()
