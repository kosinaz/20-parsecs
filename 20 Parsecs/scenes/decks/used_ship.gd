extends TextureRect

signal bought
signal helped

var _card = null
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
]
var _price = 0

var player = {
	"bought": false,
	"skipped": false,
	"money": 4000,
	"discount": 0,
}

var ship = {
	"buy": 0,
}

func set_player(player_to_set):
	player = player_to_set
	update_view()

func set_ship(ship_to_set):
	ship = ship_to_set
	
func set_card(i):
	_card = _deck[i]
	update_view()

func update_view():
	$"%ShipCard".card = _card
	$"%ShipCard".update_view()
	update_buttons()

func update_buttons():
	update_buy()
	
func disable_buttons():
	$"%Buy".disabled = true

func update_buy():
	_price = max(0, _card.buy - ship.buy - player.discount)
	$"%Buy".text = str(_price) + "K"
	if player.discount > 0 or ship.buy > 0:
		$"%Buy".text += "*"
	$"%Buy".disabled = false
	if player.bought:
		$"%Buy".disabled = true
		return
	if player.money < _price:
		$"%Buy".disabled = true
		return

func _on_buy_pressed():
	emit_signal("bought", _card, _price)


func _on_help_pressed(text):
	emit_signal("helped", text)
