extends TextureRect

signal bought
signal skipped

var _deck = [
	{
		"deck": "GearModDeck",
		"type": "Mod",
		"buy": 2,
		"name": "targeting computer",
		"patrol": "D",
		"move": 3,
	},
	{
		"deck": "GearModDeck",
		"type": "Mod",
		"buy": 2,
		"name": "quad laser",
		"attack": 1,
		"patrol": "C",
		"move": 3,
	},
	{
		"deck": "GearModDeck",
		"type": "Mod",
		"buy": 3,
		"name": "nav computer",
		"speed": 1,
	},
	{
		"deck": "GearModDeck",
		"type": "Mod",
		"buy": 3,
		"name": "shield upgrade",
		"armor": 1,
	},
	{
		"deck": "GearModDeck",
		"type": "Mod",
		"buy": 5,
		"name": "maneuvering thrusters",
		"armor": 1,
	},
	{
		"deck": "GearModDeck",
		"type": "Mod",
		"buy": 5,
		"name": "ion cannon",
		"patrol": "A",
		"move": 3,
	},
	{
		"deck": "GearModDeck",
		"type": "Mod",
		"buy": 7,
		"name": "autoblaster",
		"patrol": "B",
		"move": 3,
	},
	{
		"deck": "GearModDeck",
		"type": "Gear",
		"buy": 3,
		"name": "blaster pistol",
		"attack": 1,
		"patrol": "B",
		"move": 3,
	},
	{
		"deck": "GearModDeck",
		"type": "Gear",
		"trait": "Armor",
		"buy": 3,
		"name": "armored vest",
		"patrol": "C",
		"armor": 2,
		"move": 3,
	},
	{
		"deck": "GearModDeck",
		"type": "Gear",
		"buy": 4,
		"name": "vibroknife",
		"patrol": "B",
		"move": 4,
	},
	{
		"deck": "GearModDeck",
		"type": "Gear",
		"buy": 5,
		"name": "blaster rifle",
		"attack": 1,
		"patrol": "D",
		"move": 4,
	},
	{
		"deck": "GearModDeck",
		"type": "Gear",
		"buy": 6,
		"name": "vibroax",
		"attack": 1,
		"patrol": "A",
		"move": 3,
	},
	{
		"deck": "GearModDeck",
		"type": "Gear",
		"buy": 6,
		"name": "jetpack",
		"patrol": "A",
		"move": 4,
	},
	{
		"deck": "GearModDeck",
		"type": "Gear",
		"buy": 8,
		"name": "grenade",
		"attack": 2,
		"patrol": "D",
		"move": 3,
	},
	{
		"deck": "GearModDeck",
		"type": "Gear",
		"trait": "Armor",
		"buy": 8,
		"name": "plastoid armor",
		"patrol": "C",
		"armor": 2,
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
	if card.type == "Gear":
		$"%GearCard".show()
		$"%ModCard".hide()
		$"%GearCard".card = card
		$"%GearCard".update_view()
	else:
		$"%GearCard".hide()
		$"%ModCard".show()
		$"%ModCard".card = card
		$"%ModCard".update_view()
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
	if $"%GearCard".visible:
		for slot in player.gear_slots:
			if not slot.empty and not slot.bartering:
				continue
			if $"%GearCard".armor and (player.gear_slots[0].armor or player.gear_slots[1].armor) and not slot.bartering:
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

func front():
	return _deck.front()
	
func pop_front():
	var card = _deck.pop_front()
	update_view()
	return card

func append(card):
	_deck.append(card)

func _on_buy_pressed():
	var price = _price
	var target = _target
	var card = pop_front()
	emit_signal("bought", card, price, target)
	update_view()

func _on_skip_pressed():
	emit_signal("skipped")
	append(pop_front())
