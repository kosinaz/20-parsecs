extends TextureRect

signal bought
signal skipped

var _deck = [
#	{
#		"type": "Mod",
#		"buy": 2,
#		"name": "targeting computer",
#		"description": "Ship Combat:\n1 reroll per Blank",
#		"patrol": "D",
#		"move": 3,
#	},
#	{
#		"type": "Mod",
#		"buy": 2,
#		"name": "quad laser",
#		"description": "Attack: +1S",
#		"patrol": "C",
#		"move": 3,
#	},
#	{
#		"type": "Mod",
#		"buy": 3,
#		"name": "nav computer",
#		"description": "Speed: +1",
#	},
#	{
#		"type": "Mod",
#		"buy": 3,
#		"name": "shield upgrade",
#		"description": "Armor: +1S\nAction: Recover 1 Ship Damage",
#	},
#	{
#		"type": "Mod",
#		"buy": 5,
#		"name": "maneuvering thrusters",
#		"description": "Armor: +1S\nShip Combat\nWith Tactics:\n-1 Enemy Attack",
#	},
#	{
#		"type": "Mod",
#		"buy": 5,
#		"name": "ion cannon",
#		"description": "Ship Combat:\n-1 Enemy Hit\nWith Tactics:\n-1 Enemy Crit",
#		"patrol": "A",
#		"move": 3,
#	},
#	{
#		"type": "Mod",
#		"buy": 7,
#		"name": "autoblaster",
#		"description": "Ship Combat:\n2 Focus to Hit\nWith Tactics:\n1 Focus to Crit",
#		"patrol": "B",
#		"move": 3,
#	},
	{
		"type": "Gear",
		"buy": 3,
		"name": "blaster pistol",
		"attack": 1,
		"patrol": "B",
		"move": 3,
	},
	{
		"type": "Gear",
		"trait": "Armor",
		"buy": 3,
		"name": "armored vest",
		"patrol": "C",
		"move": 3,
	},
	{
		"type": "Gear",
		"buy": 4,
		"name": "vibroknife",
		"patrol": "B",
		"move": 4,
	},
	{
		"type": "Gear",
		"buy": 5,
		"name": "blaster rifle",
		"attack": 1,
		"patrol": "D",
		"move": 4,
	},
	{
		"type": "Gear",
		"buy": 6,
		"name": "vibroax",
		"attack": 1,
		"patrol": "A",
		"move": 3,
	},
	{
		"type": "Gear",
		"buy": 6,
		"name": "jetpack",
		"patrol": "A",
		"move": 4,
	},
	{
		"type": "Gear",
		"buy": 8,
		"name": "grenade",
		"attack": 2,
		"patrol": "D",
		"move": 3,
	},
	{
		"type": "Gear",
		"trait": "Armor",
		"buy": 8,
		"name": "plastoid armor",
		"patrol": "C",
		"move": 4,
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
	"mod_slot": {
		"visible": true,
		"empty": true,
		"bartering": false,
	},
	"cargo_mod_slot": {
		"visible": true,
		"empty": true,
		"bartering": false,
	},
}


func _ready():
	randomize()
	_deck.shuffle()
	update_view()
	
func set_player(player_to_set):
	player = player_to_set
	update_view()

func update_view():
	var card = _deck.front()
	$"%GearCard".card = card
	$"%GearCard".update_view()
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
	if $"%GearCard".visible:
		for slot in player.gear_slots:
			if not slot.empty and not slot.bartering:
				continue
			if $"%GearCard".armor and (player.gear_slots[0].armor or player.gear_slots[1].armor):
				continue
			_target = slot
			return
		_target = null
	else:
		if player.mod_slot.visible and (player.mod_slot.empty or player.mod_slot.bartering):
			_target = player.mod_slot
		elif player.cargo_mod_slot.visible and (player.cargo_mod_slot.empty or player.cargo_mod_slot.bartering):
			_target = player.cargo_mod_slot
		else:
			_target = null

func pop_front():
	var card = _deck.pop_front()
	update_view()
	return card

func append(card):
	_deck.append(card)

func _on_buy_pressed():
	emit_signal("bought", pop_front(), _price, _target)
	update_view()

func _on_skip_pressed():
	emit_signal("skipped")
	_deck.append(pop_front())
