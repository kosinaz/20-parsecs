extends Node2D

var astar = AStar2D.new()
var starter_ship_deck = StarterShipDeck.new().deck
var character_deck = CharacterDeck.new().deck
var patrol_deck = PatrolDeck.new().deck
var market_cargos = []
var market_gearmods = []
var market_ships = []
var turn = 1
var planets = [3, 5, 9, 10, 14, 25, 27, 31, 38, 39, 42]
onready var planet_spaces = [$"%Space3", $"%Space5", $"%Space9", $"%Space10", $"%Space14", $"%Space25", $"%Space27", $"%Space31", $"%Space38", $"%Space39", $"%Space42"]
var planet_names = []
var bought = false
var skipped = false
var smuggling_compartment = false
var dice = ["hit", "hit", "hit", "crit", "blank", "blank", "focus", "focus"]
var selected_contact_id = 0
var selected_contact_space = null
var selected_bounty_slot = null
var selected_contact_name = ""
var failed_cargo = null
var failed_card = 0
onready var patrols = [$"%PatrolA", $"%PatrolB", $"%PatrolC", $"%PatrolD"]
var patrol_names = ["Ahut", "Basyn", "Cimp", "Dreb"]
var reps = ["-1AR", "-1BR", "-1CR", "-1DR"]
var attacking_patrol = null
var discount = 0
var skip_encounter = false
var crew_buy = 0
onready var decks = [$"%BountyDeck", $"%CargoDeck", $"%GearModDeck", $"%JobDeck", $"%ShipDeck"]
onready var used_ships = [$"%UsedShip", $"%UsedShip2", $"%UsedShip3", $"%UsedShip4", $"%UsedShip5", $"%UsedShip6", $"%UsedShip7", $"%UsedShip8"]
onready var all_cards = []

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
	$"%Character".set_player($"%Player")
	$"%Character".set_card(character_deck[0])
	$"%Player".increase_money(4)
	$"%Ship".set_player($"%Player")
	$"%Ship".set_card(starter_ship_deck[0])
	start_planning()
# warning-ignore:return_value_discarded
	$"%BountyDeck".connect("took", self, "_on_bounty_deck_take_pressed")
# warning-ignore:return_value_discarded
	$"%BountyDeck".connect("skipped", self, "_on_skip_pressed")
# warning-ignore:return_value_discarded
	$"%JobDeck".connect("took", self, "_on_job_deck_take_pressed")
# warning-ignore:return_value_discarded
	$"%JobDeck".connect("skipped", self, "_on_skip_pressed")
# warning-ignore:return_value_discarded
	$"%CargoDeck".connect("bought", self, "_on_cargo_deck_buy_pressed")
# warning-ignore:return_value_discarded
	$"%CargoDeck".connect("skipped", self, "_on_skip_pressed")
# warning-ignore:return_value_discarded
	$"%GearModDeck".connect("bought", self, "_on_gear_mod_deck_buy_pressed")
# warning-ignore:return_value_discarded
	$"%GearModDeck".connect("skipped", self, "_on_skip_pressed")
# warning-ignore:return_value_discarded
	$"%ShipDeck".connect("bought", self, "_on_ship_deck_buy_pressed")
# warning-ignore:return_value_discarded
	$"%ShipDeck".connect("skipped", self, "_on_skip_pressed")
	all_cards.append_array(decks)
	all_cards.append_array($"%Player".slots)
	for card in all_cards:
		card.set_player($"%Player")
	for i in range(8):
		var ship = used_ships[i]
		ship.set_card(i)
		ship.set_player($"%Player")
		ship.set_ship($"%Ship")
		ship.connect("bought", self, "_on_used_ship_buy_pressed")
	$"%ShipDeck".set_ship($"%Ship")
	for card in $"%Player".gear_slots:
		card.connect("bartered", self, "_on_barter_toggled")
	for card in $"%Player".crew_slots:
		card.connect("dropped", self, "_on_drop_pressed")
	for card in $"%Player".bounty_job_slots:
		card.connect("delivered", self, "_on_bounty_deliver_pressed")
		card.connect("killed", self, "_on_bounty_kill_pressed")
		card.connect("dropped", self, "_on_drop_pressed")
	for card in $"%Player".cargo_slots:
		card.connect("moved", self, "_on_move_pressed")
		card.connect("delivered", self, "_on_deliver_pressed")
		card.connect("bartered", self, "_on_barter_toggled")
	$"%CargoModSlot".set_ship($"%Ship")
# warning-ignore:return_value_discarded
	$"%CargoModSlot".connect("moved", self, "_on_move_pressed")
# warning-ignore:return_value_discarded
	$"%CargoModSlot".connect("bartered", self, "_on_barter_toggled")
# warning-ignore:return_value_discarded
	$"%CargoModSlot".connect("repaired", self, "_on_repair_pressed")
	$"%ModSlot".set_ship($"%Ship")
# warning-ignore:return_value_discarded
	$"%ModSlot".connect("moved", self, "_on_move_pressed")
# warning-ignore:return_value_discarded
	$"%ModSlot".connect("repaired", self, "_on_repair_pressed")
# warning-ignore:return_value_discarded
	$"%ModSlot".connect("bartered", self, "_on_barter_toggled")
	for planet in planet_spaces:
		planet.connect("contacted", self, "_on_contact_pressed")
	
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
	elif $"%Character".damage > 0 or $"%Ship".damage > 0:
		$"%TurnIndicator".text += "Move or Gain 2K or Recover!"
	else:
		$"%TurnIndicator".text += "Move or Gain 2K!"
		$"%Recover".disabled = true
	astar.set_point_disabled(13)
	var hostile_patrols = []
	for r in ["A", "B", "C", "D"]:
		if $"%Player".get_reputation(r) != 1:
			var patrol = get_node("%Patrol" + r)
			var id = patrol.space.id
			astar.set_point_disabled(id)
			hostile_patrols.append(patrol)
	for to_id in astar.get_points():
		var path = astar.get_id_path($"%Player".space.id, to_id)
		if path.size() > get_speed() + 1 or path.size() == 0:
			get_node("Spaces/Space" + str(to_id)).get_node("Button").disabled = true
			get_node("Spaces/Space" + str(to_id)).get_node("Label").add_color_override("font_color", Color("9a9a9a"))
		else:
			get_node("Spaces/Space" + str(to_id)).get_node("Button").disabled = false
			get_node("Spaces/Space" + str(to_id)).get_node("Label").add_color_override("font_color", Color.white)
	astar.set_point_disabled(13, false)
	var path13 = astar.get_id_path($"%Player".space.id, 13)
	if path13.size() > get_speed() + 1 or path13.size() == 0:
		get_node("Spaces/Space13/Button").disabled = true
		get_node("Spaces/Space" + str(13)).get_node("Label").add_color_override("font_color", Color.white)
	else:
		get_node("Spaces/Space13/Button").disabled = false
		get_node("Spaces/Space" + str(13)).get_node("Label").add_color_override("font_color", Color.white)
	for patrol in hostile_patrols:
		var id = patrol.space.id
		astar.set_point_disabled(id, false)
		var path = astar.get_id_path($"%Player".space.id, id)
		if path.size() > get_speed() + 1 or path.size() == 0:
			get_node("Spaces/Space" + str(id)).get_node("Button").disabled = true
			get_node("Spaces/Space" + str(id)).get_node("Label").add_color_override("font_color", Color("9a9a9a"))
			patrol.frame = 0
		else:
			get_node("Spaces/Space" + str(id)).get_node("Button").disabled = false
			get_node("Spaces/Space" + str(id)).get_node("Label").add_color_override("font_color", Color.white)
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
	ship.space = space
	ship.space_name = space.planet_name
	ship.position = space.position

func move_patrol(patrol, step):
	var path = astar.get_id_path(patrol.space.id, $"%Player".space.id)
	if path.size() > step + 1:
		move_to(patrol, get_node("Spaces/Space" + str(path[step])))
	else:
		move_to(patrol, $"%Player".space)

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
	$"%Player".bought = false
	$"%Player".skipped = false
	$"%Ship".repaired = false
	update_action_buttons()

func stop_action():
	for card in all_cards:
		card.disable_buttons()
	$"%Finish".disabled = true
	start_encounter()

func update_action_buttons():
	$"%Player".update_discount()
	for card in all_cards:
		if planet_spaces.has($"%Player".space):
			card.update_buttons()
		else:
			card.disable_buttons()

func drop_barter_pool():
	for slot in $"%Player".slots:
		if slot.bartering:
			discard(slot)
	discount = 0

func discard(slot):
	var card = slot.get_card()
	var deck = card.deck
	get_node("%" + deck).append(card)
	if slot.has_trait("Smuggling Compartment"):
		$"%CargoSlot3".hide()
		if not $"%CargoSlot3".empty:
			if slot == $"%ModSlot":
				$"%CargoSlot3".update_target()
				var target = $"%CargoSlot3".get_target()
				if target == null:
					$"%CargoSlot3".remove_card()
				else:
					move_card($"%CargoSlot3", target)
			else:
				move_card($"%CargoSlot3", slot)
	slot.remove_card()
	
func move_card(source, target):
	var other_card = null
	if not target.empty:
		other_card = target.get_card()
	target.set_card(source.get_card())
	source.remove_card()
	if other_card:
		source.set_card(other_card)

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

func is_skilled(skill_test):
	for slot in $"%Player".skill_slots:
		if not slot.visible:
			continue
		for skill in slot.get_card().skills:
			if skill == skill_test:
				return true
	return false

func is_highly_skilled(skill_test):
	var count = 0
	for slot in $"%Player".skill_slots:
		if not slot.visible:
			continue
		for skill in slot.get_card().skills:
			if skill == skill_test:
				count += 1
	return count > 1

func has_mod(mod_name):
	return $"%ModSlot".has_mod(mod_name) or $"%CargoModSlot".has_mod(mod_name)

func has_gear(gear_name):
	return $"%GearSlot".has_gear(gear_name) or $"%GearSlot2".has_gear(gear_name)

func has_armor_gear():
	for gear in [$"%GearSlot", $"%GearSlot2"]:
		if gear.armor and not gear.bartering:
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
		if result == "blank" and has_mod("targeting computer"):
			result = roll()
			if result == "hit":
				result1 += 1
			if result == "crit":
				result1 += 2
		if result == "focus":
			if has_gear("vibroax") and not vibroaxed:
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
	var speed = $"%Ship".get_card().speed
	if has_mod("nav computer"):
		speed += 1
	return speed

func get_ship_attack():
	var attack = $"%Ship".get_card().attack
	if has_mod("quad laser"):
		attack += 1
	return attack

func get_character_attack():
	var attack = $"%Character".get_card().attack
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
	$"%Finish".disabled = true
	for i in range(8):
		$"%UsedShipMarket".get_child(i).hide()
	var start = $"%Ship".get_price() / 2.5
	for i in range(start, 8):
		var ship = $"%UsedShipMarket".get_child(i)
		ship.show()
		ship.update_view()

func buy_ship(card, price):
	$"%Player".decrease_money(price)
	drop_barter_pool()
	$"%Ship".set_card(card)
	$"%Player".bought = true
	update_ship_slots()
	update_action_buttons()

func buy_used_ship(card, price):
	$"%Player".decrease_money(price)
	drop_barter_pool()
	$"%Ship".set_card(card)
	$"%ShipDeck".erase(card)
	$"%ShipDeck".shuffle()
	$"%UsedShipMarket".hide()
	$"%Market".show()
	$"%Finish".disabled = false
	$"%Player".bought = true
	update_ship_slots()
	$"%Ship".suffer_damage(3)
	update_action_buttons()

func update_ship_slots():
	$"%CargoSlot2".visible = $"%Ship".get_card().cargo == 2
	$"%CargoModSlot".visible = $"%Ship".get_card().has("cargomod")
	$"%CrewSlot2".visible = $"%Ship".get_card().crew > 1
	$"%CrewSlot3".visible = $"%Ship".get_card().crew > 2
	$"%ModSlot".visible = $"%Ship".get_card().has("mod")
	if not $"%CargoSlot2".empty and not $"%CargoSlot2".visible:
		$"%CargoSlot2".update_target()
		if $"%CargoSlot2".get_target() == null:
			$"%CargoSlot2".remove_card()
		else:
			move_card($"%CargoSlot2", $"%CargoSlot2".get_target())
	if not $"%CargoModSlot".empty and not $"%CargoModSlot".visible:
		$"%CargoModSlot".update_target()
		if $"%CargoModSlot".get_target() == null:
			$"%CargoModSlot".remove_card()
		else:
			move_card($"%CargoModSlot", $"%CargoModSlot".get_target())
	if not $"%ModSlot".empty and not $"%ModSlot".visible:
		$"%ModSlot".update_target()
		if $"%ModSlot".get_target() == null:
			$"%ModSlot".remove_card()
		else:
			move_card($"%ModSlot", $"%ModSlot".get_target())
	if not $"%CrewSlot2".empty and not $"%CrewSlot2".visible:
		$"%CrewSlot2".remove_card()
	if not $"%CrewSlot3".empty and not $"%CrewSlot3".visible:
		$"%CrewSlot3".remove_card()

func start_encounter():
	if skip_encounter:
		stop_encounter()
		skip_encounter = false
	else:
		$"%Explore".disabled = false
		$"%Job".disabled = true
		$"%Attack".disabled = true
		$"%TurnIndicator".text = "Turn " + str(turn) + ", Encounter Step\n"
		for r in ["A", "B", "C", "D"]:
			var patrol = get_node("%Patrol" + r)
			if patrol.space == $"%Player".space:
				$"%Attack".disabled = false
				attacking_patrol = patrol
				if $"%Player".get_reputation(r) == -1:
					$"%Explore".disabled = true
		if planets.has($"%Player".space.id):
			$"%Player".space.enable_contacts()
		if $"%BountyJobSlot".get_to() == $"%Player".space_name or $"%BountyJobSlot2".get_to() == $"%Player".space_name:
			$"%Job".disabled = false

func stop_encounter():
	$"%Explore".disabled = true
	for planet in planet_spaces:
		planet.disable_contacts()
	$"%Attack".disabled = true
	$"%Job".disabled = true
	start_turn()

func attack_patrol():
	if attacking_patrol.data.has("invulnerable"):
		$"%Alert".show()
		$"%AlertSummary".text = "You failed the combat against\nthe undefeatable patrol!"
		var spaces = astar.get_point_connections($"%Player".space.id)
		move_to(attacking_patrol, get_node("Spaces/Space" + str(spaces[randi() % spaces.size()])))
		attacking_patrol = null
		$"%Ship".suffer_damage(10)
	else:
		var combat = ship_combat(get_ship_attack(), attacking_patrol.data.attack)
		$"%Ship".suffer_damage(combat.attacker_damage)
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
			var spaces = astar.get_point_connections($"%Player".space.id)
			move_to(attacking_patrol, get_node("Spaces/Space" + str(spaces[randi() % spaces.size()])))
			attacking_patrol = null

func encounter_contact():
	crew_buy = 0
	var contact_name = selected_contact_name
	$"%Join".disabled = false
	$"%Hire".disabled = false
	$"%Join".hide()
	$"%Hire".hide()
	for button in $"%Hire".get_children():
		button.hide()
	for button in $"%Join".get_children():
		button.hide()
	
	if contact_name == "Mol":
		crew_buy = 3
		if $"%BountyJobSlot".has_bounty():
			crew_buy -= 1
		if $"%BountyJobSlot2".has_bounty():
			crew_buy -= 1
		$"%CrewPrompt".show()
		$"%CrewSummary".text = "Mol is available for hire.\nProvides 1 Ground Attack and Tactics."
		$"%Join".show()
		$"%JoinMol".show()
		$"%JoinMolBuy".text = str(crew_buy)
		if $"%Player".money < crew_buy or get_available_crew_slot() == null:
			$"%Join".disabled = true
	
	if contact_name == "Anu":
		crew_buy = 2
		$"%CrewPrompt".show()
		$"%CrewSummary".text = "Anu offers Ahut Repuation."
		$"%Hire".show()
		$"%HireAnu".show()
		if $"%Player".money < crew_buy:
			$"%Hire".disabled = true
	
	if contact_name == "Nat":
		crew_buy = 1
		$"%CrewPrompt".show()
		$"%CrewSummary".text = "Nat is available for hire for someone,\nwho has a Job or Bounty.\nProvides Strength."
		$"%Join".show()
		$"%JoinNat".show()
		if $"%Player".money < crew_buy or $"%BountyJobSlot".empty and $"%BountyJobSlot2".empty:
			$"%Join".disabled = true
	
	if contact_name == "Tne":
		$"%CrewPrompt".show()
		if $"%Player".get_reputation("B") == -1:
			if not skill_test("stealth"):
				$"%Character".suffer_damage(2)
				$"%CrewSummary".text = "Tne attacked you, because of your low\nBasyn Reputation and Stealth."
			else:
				$"%CrewSummary".text = "Tne wanted to attack you, because of your low\nBasyn Reputation, but you have escaped."
		else:
			if skill_test("influence"):
				crew_buy = 0
				$"%CrewSummary".text = "You convinced Tne to join you.\nHe provides Stealth."
			else:
				crew_buy = 2
				$"%CrewSummary".text = "Tne is available for hire.\nHe provides Stealth."
				if $"%Player".money < crew_buy:
					$"%Join".disabled = true
			$"%Join".show()
			$"%JoinTne".show()
			$"%JoinTneBuy".text = str(crew_buy)
	
	if contact_name == "Keh":
		crew_buy = 2
		$"%CrewPrompt".show()
		$"%CrewSummary".text = "Keh is available for hire.\nProvides Piloting."
		$"%Join".show()
		$"%JoinKeh".show()
		if $"%Player".money < crew_buy:
			$"%Join".disabled = true
	
	if contact_name == "Acc":
		crew_buy = 4
		$"%CrewPrompt".show()
		$"%CrewSummary".text = "Acc is available for hire.\nProvides 1 Ground Armor, 2 Ship Armor,\nPiloting and Strength."
		$"%Join".show()
		$"%JoinAcc".show()
		if $"%Player".money < crew_buy:
			$"%Join".disabled = true
	
	if contact_name == "Rag":
		$"%CrewPrompt".show()
		var attack = false
		for rep in ["A", "B", "C", "D"]:
			if $"%Player".get_reputation(rep) == -1:
				attack = true
		if attack:
			var combat = ground_combat(get_character_attack(), 5)
			$"%Character".suffer_damage(combat.attacker_damage)
			if combat.attacker_won:
				$"%CrewSummary".text = "Rag attacked you because\nyou have some low reputation.\nYou have won and gained 1 Fame."
				$"%Player".increase_fame(1)
			else:
				$"%CrewSummary".text = "Rag attacked you because\nyou have some low reputation.\nYou have lost the combat."
		else:
			$"%CrewSummary".text = "Rag has no business with you."
		
			
func get_available_crew_slot():
	if $"%CrewSlot".empty:
		return $"%CrewSlot"
	if $"%CrewSlot2".empty and $"%CrewSlot2".visible:
		return $"%CrewSlot2"
	if $"%CrewSlot3".empty and $"%CrewSlot3".visible:
		return $"%CrewSlot3"
	return null

func remove_contact(contact_name):
	for planet in planet_spaces:
		planet.remove_contact(contact_name)

func start_turn():
	turn += 1
	start_planning()

func _on_space_pressed(space):
	move_to($"%Player", space)
	stop_planning()

func _on_work_pressed():
	$"%Player".increase_money(2)
	stop_planning()

func _on_finish_pressed():
	stop_action()

func _on_skip_pressed():
	$"%Player".skipped = true
	update_action_buttons()

func _on_bounty_deck_take_pressed(card, target):
	target.set_card(card)
	var front = $"%BountyDeck".front()
	if front.has("patrol"):
		move_patrol(get_node("%Patrol" + front.patrol), front.move)
	$"%Player".bought = true
	update_action_buttons()

func _on_job_deck_take_pressed(card, target):
	target.set_card(card)
	var front = $"%JobDeck".front()
	if front.has("patrol"):
		move_patrol(get_node("%Patrol" + front.patrol), front.move)
	$"%Player".bought = true
	update_action_buttons()
	
func _on_cargo_deck_buy_pressed(card, price, target):
	$"%Player".decrease_money(price)
	drop_barter_pool()
	if card.has("trait") and card.trait == "Smuggling Compartment":
		$"%CargoSlot3".show()
	target.set_card(card)
	var front = $"%CargoDeck".front()
	if front.has("patrol"):
		move_patrol(get_node("%Patrol" + front.patrol), front.move)
	$"%Player".bought = true
	update_action_buttons()
	
func _on_gear_mod_deck_buy_pressed(card, price, target):
	$"%Player".decrease_money(price)
	drop_barter_pool()
	target.set_card(card)
	var front = $"%GearModDeck".front()
	if front.has("patrol"):
		move_patrol(get_node("%Patrol" + front.patrol), front.move)
	$"%Player".bought = true
	update_action_buttons()
	$"%Character".update_armor()
	$"%Ship".update_armor()
	
func _on_ship_deck_buy_pressed(card, price):
	if card.has("used"):
		show_used_ships()
	else:
		buy_ship(card, price)

func _on_used_ship_buy_pressed(card, price):
	buy_used_ship(card, price)

func _on_deliver_pressed(cargo):
	if cargo.has_trait("Illegal"):
		failed_cargo = cargo
		var result = roll()
		failed_card = randi() % 4
		if result == "hit" or (result == "blank" and $"%CargoSlot3".visible):
			$"%Player".increase_fame(cargo.get_card().fame)
			$"%Player".increase_money(cargo.get_card().sell)
			discard(cargo)
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
						var faction = $"%Player".space.faction
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
						var faction = $"%Player".space.faction
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
		$"%Player".increase_money(cargo.get_card().sell)
		if cargo.get_card().has("rep"):
			$"%Player".increase_reputation(cargo.get_card().rep)
		discard(cargo)

func _on_bounty_deliver_pressed(slot):
	var card = slot.get_card()
	$"%Player".increase_money(card.deliver_reward)
	$"%Player".increase_fame(card.deliver_fame)
	if card.has("negative_rep"):
		$"%Player".decrease_reputation(card.negative_rep)
	if card.has("positive_rep"):
		$"%Player".increase_reputation(card.positive_rep)
	slot.remove_card()
	update_action_buttons()
	
func _on_drop_pressed(slot):
	if slot.captured or $"%Player".crew_slots.has(slot):
		slot.remove_card()
	else:
		discard(slot)
	update_action_buttons()

func _on_bounty_kill_pressed(slot):
	var card = slot.get_card()
	$"%Player".increase_money(card.kill_reward)
	$"%Player".increase_fame(card.kill_fame)
	if card.has("negative_rep"):
		$"%Player".decrease_reputation(card.negative_rep)
	slot.remove_card()
	update_action_buttons()

func _on_barter_toggled():
	update_action_buttons()

func _on_move_pressed(source, target):
	move_card(source, target)

func _on_heal_pressed():
	$"%Character".heal()
	$"%Ship".repair()
	stop_planning()

func _on_repair_pressed():
	$"%Ship".repair(1)
	$"%Ship".repaired = true

func _on_failed_sell_pressed():
	if $"%FailedSell".text == "Attack 3G":
		var combat = ground_combat(get_character_attack(), 3)
		$"%Character".suffer_damage(combat.attacker_damage)
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
		$"%Ship".suffer_damage(combat.attacker_damage)
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
		$"%Player".increase_fame(failed_cargo.get_card().fame)
		$"%Player".increase_money(failed_cargo.get_card().sell)
		discard(failed_cargo)
	$"%Prompt".hide()
	stop_action()

func _on_failed_sell2_pressed():
	if $"%FailedSell2".text == "Deliver -6K":
		$"%Player".increase_fame(failed_cargo.get_card().fame)
		$"%Player".increase_money(failed_cargo.get_card().sell - 6)
		discard(failed_cargo)
	if $"%FailedSell2".text == "Drop":
		discard(failed_cargo)
	$"%Prompt".hide()
	stop_action()

func _on_alert_button_pressed():
	$"%Alert".hide()
	stop_encounter()

func _on_explore_pressed():
	stop_encounter()
	
func _on_job_pressed():
	$"%JobAlert".show()
	$"%JobCompleted".hide()
	$"%JobFailed".hide()
	$"%JobInfluencePassed".hide()
	$"%JobInfluenceFailed".hide()
	$"%JobInfluenceFailed2".hide()
	$"%JobDiscard".hide()
	$"%JobDamage".hide()
	$"%JobDefeated".hide()
	$"%JobDefeatedSkill".hide()
	$"%JobNegativeRepButton".hide()
	$"%JobDiscardButton".hide()
	var slot = null
	if $"%BountyJobSlot".get_to() == $"%Player".space_name:
		slot = $"%BountyJobSlot"
	else:
		slot = $"%BountyJobSlot2"
	var card = slot.get_card()
	
	if card.name.ends_with("Favor"):
		if skill_test(card.skills[0]):
			$"%JobCompleted".show()
			$"%Player".increase_money(card.reward)
			if $"%Player".get_reputation(card.positive_rep) == 1:
				$"%Player".decrease_reputation(card.overclock_negative_rep)
				$"%Player".increase_fame(1)
			else: 
				$"%Player".increase_reputation(card.positive_rep)
			discard(slot)
		else:
			$"%JobFailed".show()
			if randi() % 2:
				if skill_test("influence"):
					$"%JobInfluencePassed".show()
				else:
					$"%JobInfluenceFailed".show()
					$"%JobNegativeRepButton".show()
					$"%JobRepTexture".texture = load("res://images/patrol-" + card.positive_rep.to_lower() + "-icon.png")
					$"%JobRepLabel".text = slot.get_positive_rep_name()
					$"%Player".decrease_reputation(card.positive_rep)
			else:
				if $"%Player".get_reputation(card.overclock_negative_rep) == 1:
					$"%JobDiscard".show()
					$"%JobDiscardButton".show()
					discard(slot)
					
	if card.name == "Casino Heist":
		if not skill_test("influence"):
			$"%JobFailed".show()
			$"%JobInfluenceFailed2".show()
		else:
			var fight = false
			if skill_test("tech"):
				if skill_test("strength"):
					$"%JobCompleted".show()
					$"%Player".increase_money(card.reward)
					slot.remove_card()
				else:
					fight = true
			else:
				$"%Character".suffer_damage(1)
				fight = true
			while fight:
				var combat = ground_combat(get_character_attack(), 3)
				$"%Character".suffer_damage(combat.attacker_damage)
				if $"%Character".defeated:
					$"%JobFailed".show()
					$"%JobDefeated".show()
					fight = false
				elif combat.attacker_won:
					$"%JobCompleted".show()
					if $"%Character".damage > 0:
						$"%JobDamage".show()
					$"%Player".increase_money(card.reward)
					slot.remove_card()
					fight = false
					
	if card.name == "Stash Raid":
		if not skill_test("piloting"):
			$"%Character".suffer_damage(2)
			if $"%Character".defeated:
				$"%JobFailed".show()
				$"%JobDefeatedSkill".show()
				$"%JobDefeatedSkill".text = "You are defeated, because\nyou lack enough Piloting skill."
		if not skill_test("stealth") and not $"%Character".defeated:
			$"%Character".suffer_damage(2)
			if $"%Character".defeated:
				$"%JobFailed".show()
				$"%JobDefeatedSkill".show()
				$"%JobDefeatedSkill".text = "You are defeated, because\nyou lack enough Stealth skill."
		if not skill_test("knowledge") and not $"%Character".defeated:
			$"%Character".suffer_damage(2)
			if $"%Character".defeated:
				$"%JobFailed".show()
				$"%JobDefeatedSkill".show()
				$"%JobDefeatedSkill".text = "You are defeated, because\nyou lack enough Knowledge skill."
		if not $"%Character".defeated:
			if not skill_test("tech"):
				$"%Character".suffer_damage(2)
			if $"%Character".defeated:
				$"%JobFailed".show()
				$"%JobDefeatedSkill".show()
				$"%JobDefeatedSkill".text = "You are defeated, because\nyou lack enough Tech skill."
			else:
				$"%JobCompleted".show()
				$"%Player".increase_money(card.reward)
				$"%Player".increase_fame(card.fame)
				$"%Player".decrease_reputation(card.negative_rep)
				if $"%Character".damage > 0:
					$"%JobDamage".show()
				slot.remove_card()
				
	if card.name == "Freighter Hijack":
		var damage = 0
		if not skill_test("piloting"):
			damage += 1
		if not skill_test("tech") or not skill_test("strength"):
			damage += 1
			if not skill_test("tactics"):
				damage += 1
		var tests_passed = damage == 0
		var combat = ship_combat(get_ship_attack(), 3)
		damage += combat.attacker_damage
		if combat.attacker_won and damage > 0:
			damage -= 1
		$"%Ship".suffer_damage(damage)
		if $"%Ship".defeated:
			$"%JobFailed".show()
			$"%JobDefeatedSkill".show()
			if combat.attacker_won:
				$"%JobDefeatedSkill".text = "You are defeated, because\nyou are not skilled enough."
			elif tests_passed:
				$"%JobDefeatedSkill".text = "You are defeated, because\nyou lost a ship combat."
			else:
				$"%JobDefeatedSkill".text = "You are defeated, because\nyou are not skilled enough,\nand you lost a ship combat."
		else:
			$"%JobCompleted".show()
			if $"%Character".damage > 0:
				$"%JobDamage".show()
			$"%Player".increase_money(card.reward)
			$"%Player".increase_fame(card.fame)
			slot.remove_card()
			
	if card.name == "Jewel Heist":
		var damage = 0
		if not skill_test("knowledge"):
			damage += 1
		if not skill_test("tactics"):
			if $"%Player".money >= 3:
				$"%Player".decrease_money(3)
				$"%JobMoney".show()
			else:
				damage += 1
		if not skill_test("influence"):
			damage += 1
		if not skill_test("stealth"):
			damage += 2
		if not skill_test("tech"):
			var combat = ground_combat(get_character_attack(), 4)
			damage += combat.attacker_damage
			if combat.attacker_won and damage > 0:
				damage -= 2
			$"%Character".suffer_damage(damage)
			if $"%Character".defeated:
				$"%JobFailed".show()
				$"%JobDefeatedSkill".show()
				if combat.attacker_won:
					$"%JobDefeatedSkill".text = "You are defeated, because\nyou are not skilled enough."
				else:
					$"%JobDefeatedSkill".text = "You are defeated, because\nyou are not skilled enough,\nand you lost a ground combat."
			else:
				$"%JobCompleted".show()
				if $"%Character".damage > 0:
					$"%JobDamage".show()
				$"%Player".increase_money(card.reward)
				$"%Player".increase_fame(card.fame)
				slot.remove_card()
		else:
			$"%JobCompleted".show()
			if $"%Character".damage > 0:
				$"%JobDamage".show()
			$"%Player".increase_money(card.reward)
			$"%Player".increase_fame(card.fame)
			slot.remove_card()
			
	if card.name == "Ekes Run":
		if not skill_test("influence"):
			$"%JobFailed".show()
			$"%JobDefeatedSkill".show()
			$"%JobDefeatedSkill".text = "Because you don't have enough Influence."
		elif not skill_test("strength"):
			$"%JobFailed".show()
			$"%JobDefeatedSkill".show()
			$"%JobDefeatedSkill".text = "Because you don't have enough Strength."
		else:
			var damage = 0
			if not skill_test("tactics"):
				damage += 2
			if not skill_test("knowledge"):
				damage += 2
			move_to($"%Player", $Spaces/Space13)
			while not skill_test("piloting"):
				damage += 1
			$"%Ship".suffer_damage(damage)
			$"%JobCompleted".show()
			if $"%Ship".defeated:
				$"%JobDefeatedSkill".show()
				$"%JobDefeatedSkill".text = "But your ship is defeated due to\ntoo many failed skills tests."
			elif damage > 0:
				$"%JobDamage".show()
			$"%Player".increase_money(card.reward)
			$"%Player".increase_fame(card.fame)
			slot.remove_card()
			
	if card.name == "Temple Raid":
		if not skill_test("knowledge"):
			$"%JobFailed".show()
			$"%JobDefeatedSkill".show()
			$"%JobDefeatedSkill".text = "Because you don't have enough Knowledge."
		else:
			var damage = 0
			if not skill_test("stealth"):
				damage += 1
			while not skill_test("tactics"):
				damage += 1
			$"%Character".suffer_damage(damage)
			$"%JobCompleted".show()
			if $"%Character".defeated:
				$"%JobDefeatedSkill".show()
				$"%JobDefeatedSkill".text = "But you are defeated,\nbecause you don't have enough Tactics."
			elif damage > 0:
				$"%JobDamage".show()
			$"%Player".increase_money(card.reward)
			$"%Player".increase_fame(card.fame)
			slot.remove_card()
			
	if card.name == "Mine Rescue":
		var step = 1
		var damage = 0
		if skill_test("knowledge"):
			step = 2
		else:
			step = 3
		if step == 2:
			if skill_test("stealth"):
				step = 5
			else:
				step = 3
		if step == 3:
			var combat = ground_combat(get_character_attack(), 4)
			damage += combat.attacker_damage
			if combat.attacker_won:
				step = 5
			else:
				step = 4
		if step == 4:
			while not skill_test("strength"):
				damage += 1
			step = 5
		if step == 5:
			while not skill_test("strength"):
				damage += 1
			$"%Character".suffer_damage(damage)
			$"%JobCompleted".show()
			if $"%Character".defeated:
				$"%JobDefeatedSkill".show()
				$"%JobDefeatedSkill".text = "But you are defeated,\nbecause you don't have enough Strength."
			elif damage > 0:
				$"%JobDamage".show()
			$"%Player".increase_money(card.reward)
			$"%Player".increase_fame(card.fame)
			$"%Player".decrease_reputation(card.negative_rep)
			slot.remove_card()
			
	if card.name == "Spy Hunt":
		var step = 1
		var damage = 0
		if skill_test("influence"):
			step = 3
		else:
			step = 2
		if step == 2:
			var combat = ground_combat(get_character_attack(), 3)
			damage += combat.attacker_damage
			if combat.attacker_won and damage > 0:
				damage -= 1
			step = 3
		if step == 3:
			while not skill_test("knowledge"):
				damage += 1
			step = 4
		if step == 4:
			while not skill_test("tactics"):
				damage += 1
			step = 4
			$"%Character".suffer_damage(damage)
			$"%JobCompleted".show()
			if $"%Character".defeated:
				$"%JobDefeatedSkill".show()
				$"%JobDefeatedSkill".text = "But you are defeated,\nbecause you don't have enough skills."
			elif damage > 0:
				$"%JobDamage".show()
			$"%Player".increase_money(card.reward)
			$"%Player".increase_fame(card.fame)
			slot.remove_card()
	stop_encounter()

func _on_attack_pressed():
	attack_patrol()

func _on_contact_pressed(space, id):
	if space.contacts[id].name == "":
		space.add_contact(id, $"%ContactDeck".deck[space.contacts[id].level - 1].pop_front())
	selected_contact_id = id
	selected_contact_space = space
	selected_contact_name = space.contacts[id].name
	selected_bounty_slot = $"%Player".get_bounty(space.contacts[id].name)
	if selected_bounty_slot != null:
		$"%ContactPrompt".show()
		$"%BountyLevel".texture = load("res://images/person" + str(space.contacts[id].level) + ".png")
		$"%BountyNameLabel".text = space.contacts[id].name
		if selected_bounty_slot.get_card().attack_type == "GroundAttack":
			$"%CombatTexture".texture = load("res://images/ground-combat.png")
			$"%CombatLabel".text = "Ground Combat"
			$"%AttackTexture".texture = load("res://images/ground-attack.png")
			$"%AttackLabel".text = "Ground Attack"
		else:
			$"%CombatTexture".texture = load("res://images/ship-combat.png")
			$"%CombatLabel".text = "Ship Combat"
			$"%AttackTexture".texture = load("res://images/ship-attack.png")
			$"%AttackLabel".text = "Ship Attack"
		$"%AttackValue".text = str(selected_bounty_slot.get_card().attack)
	else:
		encounter_contact()

func _on_attack_contact_pressed():
	$"%ContactPrompt".hide()
	var card = selected_bounty_slot.get_card()
	var combat = null
	if card.attack_type == "GroundAttack":
		combat = ground_combat(get_character_attack(), card.attack)
		$"%Character".suffer_damage(combat.attacker_damage)
	else:
		combat = ship_combat(get_ship_attack(), card.attack)
		$"%Ship".suffer_damage(combat.attacker_damage)
	if combat.attacker_won:
		$"%ContactPrompt2".show()
		$"%DefeatedBountyLevel".texture = load("res://images/person" + str(selected_contact_space.contacts[selected_contact_id].level) + ".png")
		$"%DefeatedBountyNameLabel".text = selected_contact_space.contacts[selected_contact_id].name
		$"%ContactDefenderDamage".text = str(combat.defender_damage)
		$"%ContactAttackerDamage".text = str(combat.attacker_damage)
		$"%BountyKillReward".text = str(card.kill_reward)
		$"%BountyKillFame".text = str(card.kill_fame)
		$"%BountyDeliverTo".text = card.to
		$"%BountyDeliverReward".text = str(card.deliver_reward)
		$"%BountyDeliverFame".text = str(card.deliver_fame)
		$"%NegativeRepContainer".hide()
		$"%NegativeRepContainer2".hide()
		$"%PositiveRepContainer".hide()
		$"%DeliverRepContainer".hide()
		if card.has("negative_rep"):
			$"%NegativeRepContainer".show()
			$"%NegativeRepContainer2".show()
			$"%DeliverRepContainer".show()
			$"%NegativeRepLabel".text = selected_bounty_slot.get_negative_rep_name()
			$"%NegativeRepLabel2".text = selected_bounty_slot.get_negative_rep_name()
			$"%NegativeRepTexture".texture = load("res://images/patrol-" + (card.negative_rep.to_lower()) + "-icon.png")
			$"%NegativeRepTexture2".texture = load("res://images/patrol-" + (card.negative_rep.to_lower()) + "-icon.png")
		if card.has("positive_rep"):
			$"%PositiveRepContainer".show()
			$"%DeliverRepContainer".show()
			$"%PositiveRepLabel".text = selected_bounty_slot.get_positive_rep_name()
			$"%PositiveRepTexture".texture = load("res://images/patrol-" + (card.positive_rep.to_lower()) + "-icon.png")
	else:
		$"%ContactAlert".show()
		$"%ContactAlertDefenderDamage".text = str(combat.defender_damage)
		$"%ContactAlertAttackerDamage".text = str(combat.attacker_damage)

func _on_encounter_contact_pressed():
	$"%ContactPrompt".hide()
	encounter_contact()

func _on_contact_alert_button_pressed():
	$"%ContactAlert".hide()
	stop_encounter()

func _on_job_alert_button_pressed():
	$"%JobAlert".hide()
	stop_encounter()

func _on_kill_bounty_pressed():
	$"%ContactPrompt2".hide()
	var card = selected_bounty_slot.get_card()
	$"%Player".increase_money(card.kill_reward)
	$"%Player".increase_fame(card.kill_fame)
	if card.has("negative_rep"):
		$"%Player".decrease_reputation(card.negative_rep)
	remove_contact(card.name)
	selected_bounty_slot.remove_card()
	stop_encounter()

func _on_capture_bounty_pressed():
	$"%ContactPrompt2".hide()
	var card = selected_bounty_slot.get_card()
	remove_contact(card.name)
	selected_bounty_slot.capture()
	stop_encounter()

func _on_hire_pressed():
	if $"%HireAnu".visible:
		$"%Player".decrease_money(crew_buy)
		$"%Player".increase_reputation("A")
	$"%CrewPrompt".hide()
	stop_encounter()

func _on_dismiss_pressed():
	$"%CrewPrompt".hide()
	stop_encounter()

func _on_join_pressed():
	if crew_buy > 0:
		$"%Player".decrease_money(crew_buy)
	var target = get_available_crew_slot()
	target.set_card($"%CrewDeck".deck[selected_contact_name])
	remove_contact(selected_contact_name)
	$"%CrewPrompt".hide()
	stop_encounter()
