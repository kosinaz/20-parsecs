extends TextureRect

signal bought
signal skipped
signal helped

var _deck = [
	{
		"deck": "CargoDeck",
		"type": "Cargo",
		"to": "Ganal",
		"buy": 1,
		"sell": 5,
		"rep": "A",
		"patrol": "A",
		"move": 4,
	},
	{
		"deck": "CargoDeck",
		"type": "Cargo",
		"to": "Bord",
		"buy": 1,
		"sell": 5,
		"rep": "B",
		"patrol": "B",
		"move": 4,
	},
	{
		"deck": "CargoDeck",
		"type": "Cargo",
		"to": "Haryl",
		"buy": 1,
		"sell": 5,
		"rep": "C",
		"patrol": "C",
		"move": 4,
	},
	{
		"deck": "CargoDeck",
		"type": "Cargo",
		"to": "Damon",
		"buy": 1,
		"sell": 5,
		"rep": "D",
		"patrol": "D",
		"move": 4,
	},
	{
		"deck": "CargoDeck",
		"type": "Cargo",
		"to": "Katak",
		"buy": 1,
		"sell": 6,
		"patrol": "A",
		"move": 3,
	},
	{
		"deck": "CargoDeck",
		"type": "Cargo",
		"trait": "Illegal",
		"to": "Acan",
		"buy": 2,
		"sell": 7,
		"fame": 1
	},
	{
		"deck": "CargoDeck",
		"type": "Cargo",
		"trait": "Illegal",
		"to": "Ekes",
		"buy": 2,
		"sell": 7,
		"fame": 1,
		"patrol": "B",
		"move": 3,
	},
	{
		"deck": "CargoDeck",
		"type": "Cargo",
		"trait": "Illegal",
		"to": "Fatat",
		"buy": 2,
		"sell": 7,
		"fame": 1,
		"patrol": "C",
		"move": 3,
	},
	{
		"deck": "CargoDeck",
		"type": "Cargo",
		"trait": "Illegal",
		"to": "Jakaf",
		"buy": 3,
		"sell": 9,
		"fame": 1,
		"patrol": "D",
		"move": 3,
	},
	{
		"deck": "CargoDeck",
		"type": "Cargo/Mod",
		"trait": "Smuggling Compartment",
		"buy": 2,
		"name": "smuggling compartment",
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
	}
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
	$"%CargoCard".card = card
	$"%CargoCard".update_view()
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

func _on_help_pressed(text):
	emit_signal("helped", text)
