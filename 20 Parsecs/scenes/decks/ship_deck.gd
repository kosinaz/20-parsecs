extends TextureRect

signal bought
signal skipped

var _deck = [
	{
		"buy": 5,
		"name": "Freighter",
		"speed": 6,
		"attack": 3,
		"armor": 4,
		"cargo": 1,
		"mod": 1,
		"crew": 2,
	},
	{
		"buy": 5,
		"name": "Hauler",
		"speed": 6,
		"attack": 2,
		"armor": 5,
		"cargo": 1,
		"cargomod": 1,
		"crew": 2,
	},
	{
		"buy": 10,
		"name": "Lifter",
		"speed": 6,
		"attack": 3,
		"armor": 5,
		"cargo": 1,
		"cargomod": 1,
		"crew": 3,
	},
	{
		"buy": 10,
		"name": "Pursuiter",
		"speed": 6,
		"attack": 4,
		"armor": 5,
		"cargo": 1,
		"mod": 1,
		"crew": 2,
	},
	{
		"buy": 15,
		"name": "Freighter2",
		"speed": 7,
		"attack": 3,
		"armor": 5,
		"cargo": 2,
		"cargomod": 1,
		"crew": 3,
	},
	{
		"buy": 15,
		"name": "Fighter2",
		"speed": 6,
		"attack": 5,
		"armor": 5,
		"cargo": 1,
		"cargomod": 1,
		"mod": 1,
		"crew": 2,
	},
	{
		"buy": 20,
		"name": "Patroler",
		"speed": 6,
		"attack": 5,
		"armor": 6,
		"cargo": 1,
		"cargomod": 1,
		"mod": 1,
		"crew": 2,
	},
	{
		"buy": 20,
		"name": "Freighter3",
		"speed": 7,
		"attack": 4,
		"armor": 5,
		"cargo": 1,
		"cargomod": 1,
		"mod": 1,
		"crew": 3,
	},
	{
		"used": true,
	},
]
var _price = 0

var player = {
	"bought": false,
	"skipped": false,
	"money": 4000,
	"discount": 0,
}

var ship = {
	"buy": 5,
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
	$"%ShipCard".card = card
	$"%ShipCard".update_view()
	update_buttons()

func update_buttons():
	update_buy()
	update_skip()
	
func disable_buttons():
	$"%Buy".disabled = true
	$"%Skip".disabled = true

func update_buy():
	var card = _deck.front()
	_price = max(0, card.buy - ship.buy - player.discount)
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
	
func update_skip():
	if player.bought:
		$"%Skip".disabled = true
		return
	$"%Skip".disabled = player.skipped

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
	var card = pop_front()
	emit_signal("bought", card, price)

func _on_skip_pressed():
	emit_signal("skipped")
	append(pop_front())
