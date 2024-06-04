extends TextureRect

signal bought
signal skipped

var _deck = [
	{
		"deck": "LuxuryDeck",
		"type": "Cargo",
		"buy": 10,
		"trait": "Holotable",
	},
	{
		"deck": "LuxuryDeck",
		"type": "Cargo",
		"to": "Fatat",
		"buy": 20,
		"sell": 0,
		"fame": 2,
		"rep": "A",
		"patrol": "A",
		"move": 4,
	},
	{
		"deck": "LuxuryDeck",
		"type": "Gear",
		"trait": "Armor",
		"buy": 10,
		"name": "nai armor",
		"armor": 3,
		"patrol": "A",
		"move": 3,
	},
	{
		"deck": "LuxuryDeck",
		"type": "Gear",
		"buy": 15,
		"name": "robe",
		"patrol": "B",
		"move": 4,
	},
	{
		"deck": "LuxuryDeck",
		"type": "Mod",
		"buy": 15,
		"attack": 1,
		"name": "torpedo",
		"patrol": "D",
		"move": 4,
	},
	{
		"deck": "LuxuryDeck",
		"type": "Mod",
		"buy": 20,
		"name": "chrome",
		"patrol": "C",
		"move": 4,
	},
	{
		"deck": "LuxuryDeck",
		"type": "Crew",
		"buy": 10,
		"name": "Sel",
		"skills": ["influence", "tactics"],
	},
	{
		"deck": "LuxuryDeck",
		"type": "Crew",
		"buy": 10,
		"name": "Rev",
		"skills": ["stealth"],
	},
]

var _target = null
var _price = 0

var player = {
	"bought": false,
	"skipped": false,
	"money": 4000,
	"discount": 0,
	"space_name": "Acan",
	"cargo_slots": [
		{
			"visible": true,
			"empty": true,
			"bartering": false,
		},
		{
			"visible": false,
			"empty": true,
			"bartering": false,
		},
	],
	"cargo_mod_slot": {
		"visible": true,
		"empty": true,
		"bartering": false,
	},
	"mod_slot": {
		"visible": true,
		"empty": true,
		"bartering": false,
	},
	"gear_slots": [
		{
			"visible": true,
			"empty": true,
			"bartering": false,
			"armor": false,
		},
		{
			"visible": true,
			"empty": true,
			"bartering": false,
			"armor": false,
		}
	],
	"crew_slots": [
		{
			"visible": true,
			"empty": true,
			"bartering": false,
		},
		{
			"visible": true,
			"empty": true,
			"bartering": false,
		},
		{
			"visible": true,
			"empty": true,
			"bartering": false,
		},
	],
}


func _ready():
	randomize()
	_deck.shuffle()
	update_view()
	
func set_player(player_to_set):
	player = player_to_set
	update_view()

func update_view():
	for card in $"%Card".get_children():
		card.hide()
	$"%Bottom".show()
	var card = _deck.front()
	if card.type == "Cargo":
		$"%CargoCard".show()
		$"%CargoCard".card = card
		$"%CargoCard".update_view()
	if card.type == "Gear":
		$"%GearCard".show()
		$"%GearCard".card = card
		$"%GearCard".update_view()
	if card.type == "Mod":
		$"%ModCard".show()
		$"%ModCard".card = card
		$"%ModCard".update_view()
	if card.type == "Crew":
		$"%CrewCard".show()
		$"%CrewCard".card = card
		$"%CrewCard".update_view()
	update_buttons()

func update_buttons():
	update_buy()
	update_skip()
	
func disable_buttons():
	$"%Buy".disabled = true
	$"%Skip".disabled = true

func update_buy():
	var card = _deck.front()
	_price = max(0, card.buy - player.discount)
	$"%Buy".text = str(_price) + "K"
	if player.discount > 0:
		$"%Buy".text += "*"
	$"%Buy".disabled = false
	if player.bought:
		$"%Buy".disabled = true
		return
	if player.money < _price:
		$"%Buy".disabled = true
		return
	if card.has("to") and player.space_name == card.to:
		$"%Buy".disabled = true
		return
	update_target()
	if _target == null:
		$"%Buy".disabled = true
	
func update_skip():
	if player.bought:
		$"%Skip".disabled = true
		return
	$"%Skip".disabled = player.skipped

func update_target():
	_target = null
	var targets = []
	if $"%CargoCard".visible:
		targets.append_array(player.cargo_slots)
		targets.append(player.cargo_mod_slot)
		if front().type == "Cargo/Mod":
			targets.append(player.mod_slot)
		for target in targets:
			if not target.visible:
				continue
			if not target.empty and not target.bartering:
				continue
			_target = target
			return
	if $"%CrewCard".visible:
		for slot in player.crew_slots:
			if slot.empty:
				_target = slot
				return
	if $"%GearCard".visible:
		for slot in player.gear_slots:
			if not slot.empty and not slot.bartering:
				continue
			if $"%GearCard".armor and (player.gear_slots[0].armor or player.gear_slots[1].armor) and not slot.bartering:
				continue
			_target = slot
			return
		_target = null
	if $"%ModCard".visible:
		if player.mod_slot.visible and (player.mod_slot.empty or player.mod_slot.bartering):
			_target = player.mod_slot
		elif player.cargo_mod_slot.visible and (player.cargo_mod_slot.empty or player.cargo_mod_slot.bartering):
			_target = player.cargo_mod_slot
		else:
			_target = null

func front():
	return _deck.front()

func pop_front():
	var card = _deck.pop_front()
	update_view()
	return card

func append(card):
	_deck.append(card)

func _on_buy_pressed():
	var target = _target
	var price = _price
	var card = pop_front()
	emit_signal("bought", card, price, target)

func _on_skip_pressed():
	emit_signal("skipped")
	append(pop_front())
