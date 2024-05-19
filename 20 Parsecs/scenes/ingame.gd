extends Node2D

var astar = AStar2D.new()
var gearmod_deck = GearmodDeck.new().deck
var ship_deck = ShipDeck.new().deck
var starter_ship_deck = StarterShipDeck.new().deck
var character_deck = CharacterDeck.new().deck
var patrol_deck = PatrolDeck.new().deck
var market_cargos = []
var market_gearmods = []
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
onready var market_slots = [$"%MarketCargo", $"%MarketGearmod", $"%MarketShip"]
onready var ship_slots = [$"%ShipCargo", $"%ShipCargo2", $"%ShipCargo3", $"%ShipCargomod", $"%ShipMod"]
onready var character_slots = [$"%CharacterGear", $"%CharacterGear2"]
onready var all_cards = []

func _ready():
	all_cards.append_array(market_slots)
	all_cards.append_array(ship_slots)
	all_cards.append_array(character_slots)
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
	market_gearmods.append_array(gearmod_deck)
	market_gearmods.shuffle()
	market_ships.append_array(ship_deck)
	market_ships.shuffle()
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
	var hostile_patrols = []
	for r in ["A", "B", "C", "D"]:
		if $"%Player".get_reputation(r) != 1:
			var patrol = get_node("%Patrol" + r)
			var id = patrol.current_space.id
			astar.set_point_disabled(id)
			hostile_patrols.append(patrol)
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
	for patrol in hostile_patrols:
		var id = patrol.current_space.id
		astar.set_point_disabled(id, false)
		var path = astar.get_id_path($"%Player".current_space.id, id)
		if path.size() > get_speed() + 1 or path.size() == 0:
			get_node("Spaces/Space" + str(id)).get_node("Button").disabled = true
			get_node("Spaces/Space" + str(id)).get_node("Label").add_color_override("font_color", Color("9a9a9a"))
			get_node("Spaces/Space" + str(id)).get_node("Faction").add_color_override("font_color", Color("9a9a9a"))
			patrol.frame = 0
		else:
			get_node("Spaces/Space" + str(id)).get_node("Button").disabled = false
			get_node("Spaces/Space" + str(id)).get_node("Label").add_color_override("font_color", Color.white)
			get_node("Spaces/Space" + str(id)).get_node("Faction").add_color_override("font_color", Color.white)
			patrol.frame = 1

func stop_planning():
	for space in $Spaces.get_children():
		space.get_node("Button").disabled = true
	for patrol in patrols:
		patrol.frame = 0
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
	for card in all_cards:
		card.disable_buttons()
	$"%Finish".disabled = true
	start_encounter()

func update_action_buttons():
	for card in all_cards:
		card.enable_buttons()
	if skipped:
		for card in market_slots:
			card.disable_button("Skip")
	if bought or not planets.has($"%Player".current_space.id):
		for card in market_slots:
			card.disable_buttons()
		for card in ship_slots:
			card.disable_button("Barter")
		for card in character_slots:
			card.disable_button("Barter")
	if $"%Ship".get_damage() == 0:
		$"%ShipMod".disable_button("Recover")
		$"%ShipCargomod".disable_button("Recover")
	for card in ship_slots:
		if card.is_cargo and $"%Player".current_space.get_node("Label").text != card.get_to():
			card.disable_button("Deliver")
	update_card_movement_targets()
	update_buy_buttons()
	for card in ship_slots:
		if card.movement_target == null:
			card.disable_button("Move")
	update_market_prices()

func update_buy_buttons():
	for card in [$"%MarketCargo", $"%MarketGearmod"]:
		if $"%Player".get_money() < card.get_price() - discount:
			card.disable_button("Buy")
	if $"%MarketShip".is_used():
		if $"%Player".get_money() < 5 or $"%Ship".get_price() == 20 or $"%Player".get_money() < $"%MarketShip".get_price() - $"%Ship".get_price():
			$"%MarketShip".disable_button("Buy")
	if $"%Player".current_space.get_node("Label").text == $"%MarketCargo".get_to():
		$"%MarketCargo".disable_button("Buy")
	for card in market_slots:
		if card.moveable and card.movement_target == null:
			card.disable_button("Buy")

func update_card_movement_targets():
	for card in all_cards:
		if not card.moveable:
			continue
		card.movement_target = null
		var available_targets = []
		available_targets.append_array(ship_slots)
		available_targets.append_array(character_slots)
		if card.get_data().has("smuggling compartment"):
			available_targets.erase($"%ShipCargo3")
		if not card.is_cargo:
			available_targets.erase($"%ShipCargo")
			available_targets.erase($"%ShipCargo2")
			available_targets.erase($"%ShipCargo3")
		if not card.is_mod:
			available_targets.erase($"%ShipMod")
		if not card.is_mod and not card.is_cargo:
			available_targets.erase($"%ShipCargomod")
		if not card.is_gear:
			available_targets.erase($"%CharacterGear")
			available_targets.erase($"%CharacterGear2")
		if card.is_market:
			for available_target in available_targets:
				if not available_target.visible:
					continue
				if not available_target.is_empty and not available_target.is_bartering():
					continue
				if card.is_gear and card.is_armor() and has_armor_gear():
					continue
				card.movement_target = available_target
				break
		else:
			var i = available_targets.find(card)
			var available_targets_ordered = []
			available_targets_ordered.append_array(available_targets)
			available_targets_ordered.erase(card)
			if i > 0:
				available_targets_ordered = available_targets.slice(i + 1, available_targets.size())
				available_targets_ordered.append_array(available_targets.slice(0, i - 1))
			for available_target in available_targets_ordered:
				if not available_target.visible:
					continue
				if not available_target.is_empty:
					if available_target.get_data().has("smuggling compartment") and card == $"%ShipCargo3":
						continue
					if available_target.is_cargo and card.is_ship_cargo:
						card.movement_target = available_target
						break
					if available_target.is_mod and card.is_ship_mod:
						card.movement_target = available_target
						break
				else:
					card.movement_target = available_target
					break

func update_market_prices():
	discount = 0
	for card in ship_slots:
		if card.is_bartering():
			discount += card.get_price()
	for card in character_slots:
		if card.is_bartering():
			discount += card.get_price()
	for card in market_slots:
		if not card.is_free:
			var reduced_price = max(0, card.get_price() - discount)
			card.set_buy_text("Buy " + str(reduced_price) + "K")
	var reduced_ship_price = max(0, $"%MarketShip".get_price() - discount - $"%Ship".get_price())
	$"%MarketShip".set_buy_text("Buy " + str(reduced_ship_price) + "K")
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

func drop_cargo(cargo):
	if cargo.get_data().has("smuggling compartment"):
		smuggling_compartment = false
		$"%ShipCargo3".hide()
		remove_cargo(cargo)
#		if $"%ShipCargo3".has_cargo:
#			cargo.setup($"%ShipCargo3".get_data())
#			remove_cargo($"%ShipCargo3")
	else:
		remove_cargo(cargo)

func drop_mod(mod):
	if mod.get_data().has("smuggling compartment"):
		smuggling_compartment = false
		$"%ShipCargo3".hide()
#		if $"%ShipCargo3".has_cargo:
#			remove_cargo($"%ShipCargo3")
#		remove_cargo(mod)
	else:
		market_gearmods.append(mod.get_data())
		mod.clear()
	update_action_buttons()
	$"%Ship".update_armor()

func drop_gear(gear):
	market_gearmods.append(gear.get_data())
	gear.clear()
	update_action_buttons()
	$"%Character".update_armor()

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

func has_mod(name):
	return $"%ShipMod".get_name() == name or $"%ShipCargomod".get_name() == name

func has_gear(name):
	return $"%CharacterGear".get_name() == name or $"%CharacterGear2".get_name() == name

func has_armor_gear():
	for gear in [$"%CharacterGear", $"%CharacterGear2"]:
		if gear.is_armor() and not gear.is_bartering():
			return true
	return false

func ground_combat(attack1, attack2):
	if has_gear("plastoid_armor") and is_skilled("Strength"):
		attack2 -= 1
	var result1 = 0
	var vibroknifed = false
	var vibroaxed = false
	for _i in range(attack1):
		var result = roll()
		if result == "hit":
			result1 += 1
		if result == "crit":
			result1 += 2
#		if result == "blank" and has_mod("targeting computer"):
#			result = roll()
#			if result == "hit":
#				result1 += 1
#			if result == "crit":
#				result1 += 2
		if result == "focus":
			if has_gear("vibroax") and not vibroknifed:
				vibroaxed = true
				result1 += 2
			elif has_gear("vibroknife") and not vibroknifed:
				vibroknifed = true
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
	if has_gear("jetpack"):
		if has_crit and is_skilled("Tactics"):
			result2 -= 2
		elif has_hit:
			result2 -= 1
	if has_gear("blaster rifle"):
		result2 = min(result2, 2)
	return {
		"attacker_won": result2 <= result1,
		"attacker_damage": result2,
		"defender_damage": result1,
	}

func ship_combat(attack1, attack2):
	if has_mod("maneuvering thrusters") and is_skilled("Tactics"):
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
		if result == "blank" and has_mod("targeting computer"):
			result = roll()
			if result == "hit":
				result1 += 1
			if result == "crit":
				result1 += 2
		if result == "focus" and has_mod("autoblaster"):
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
	if has_mod("ion cannon"):
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
	if has_mod("nav computer"):
		speed += 1
	return speed

func get_ship_attack():
	var attack = $"%Ship".get_data().attack
	if has_mod("quad laser"):
		attack += 1
	return attack

func get_character_attack():
	var attack = $"%Character".get_data().attack
	if has_gear("blaster pistol"):
		attack += 1
	if has_gear("blaster rifle"):
		attack += 1
	if has_gear("grenade"):
		attack += 2
	if has_gear("vibroknife") and (is_skilled("Stealth") or is_skilled("Strength")):
		attack += 1
	return attack

func show_used_ships():
	$"%UsedShipMarket".show()
	$"%Market".hide()
	for card in ship_slots:
		card.disable_button("Deliver")
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
	update_ship_cargos_and_mods()
	bought = true
	$"%Ship".damage(3)
	update_action_buttons()

func update_ship_cargos_and_mods():
	if $"%Ship".get_data().cargo == 2:
		$"%ShipCargo2".show()
	else:
		$"%ShipCargo2".hide()
	if $"%Ship".get_data().has("cargomod"):
		$"%ShipCargomod".show()
	else:
		$"%ShipCargomod".hide()
	if $"%Ship".get_data().has("mod"):
		$"%ShipMod".show()
	else:
		$"%ShipMod".hide()

func buy_ship(ship):
	$"%Player".decrease_money(max(0, ship.buy - discount - $"%Ship".get_price()))
	drop_barter_pool()
	$"%Ship".setup(ship)
	market_ships.pop_front()
	$"%MarketShip".setup(market_ships[0])
	update_ship_cargos_and_mods()
	bought = true
	update_action_buttons()

func drop_barter_pool():
	if $"%ShipCargo".get_node("Barter").pressed:
		drop_cargo($"%ShipCargo")
	if $"%ShipCargo2".get_node("Barter").pressed:
		drop_cargo($"%ShipCargo2")
	if $"%ShipCargo3".get_node("Barter").pressed:
		drop_cargo($"%ShipCargo3")
	if $"%ShipCargomod".get_node("Barter").pressed:
		drop_mod($"%ShipCargomod")
	if $"%ShipMod".get_node("Barter").pressed:
		drop_mod($"%ShipMod")
	if $"%CharacterGear".is_bartering():
		drop_gear($"%CharacterGear")
	if $"%CharacterGear2".is_bartering():
		drop_gear($"%CharacterGear2")
	discount = 0
	
func move_card(card):
	var other_data = card.movement_target.get_data()
	card.movement_target.setup(card.get_data())
	card.clear()
	if other_data:
		card.setup(other_data)
	update_action_buttons()

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
		var combat = ship_combat(get_ship_attack(), attacking_patrol.data.attack)
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
	$"%MarketCargo".movement_target.setup(market_cargos[0])
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
	$"%MarketGearmod".movement_target.setup(market_gearmods[0])
	$"%Ship".update_armor()
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

func _on_character_gear_drop_pressed():
	drop_gear($"%CharacterGear")

func _on_character_gear2_drop_pressed():
	drop_gear($"%CharacterGear2")

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

func _on_ship_cargomod_deliver_pressed():
	deliver_cargo($"%ShipCargomod")

func _on_ship_cargomod_drop_pressed():
	drop_cargo($"%ShipCargomod")
	
func _on_ship_mod_drop_pressed():
	drop_mod($"%ShipMod")
	
func _on_ship_cargo_barter_toggled(_pressed):
	update_action_buttons()

func _on_ship_cargo_move_pressed():
	move_card($"%ShipCargo")
	
func _on_ship_cargo2_move_pressed():
	move_card($"%ShipCargo2")
	
func _on_ship_cargo3_move_pressed():
	move_card($"%ShipCargo3")
	
func _on_ship_cargomod_move_pressed():
	move_card($"%ShipCargomod")
	
func _on_ship_mod_move_pressed():
	move_card($"%ShipMod")

func _on_ship_mod_recover_pressed():
	$"%Ship".repair(1)
	$"%ShipMod".disable_recover()

func _on_ship_cargomod_recover_pressed():
	$"%Ship".repair(1)
	$"%ShipCargomod".disable_recover()

func _on_failed_sell_pressed():
	if $"%FailedSell".text == "Attack 3G":
		var combat = ground_combat(get_character_attack(), 3)
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
		var combat = ship_combat(get_ship_attack(), 3)
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


