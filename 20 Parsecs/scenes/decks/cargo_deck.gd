extends TextureRect

signal bought
signal skipped

var _deck = [
	{
		"type": "Cargo",
		"to": "Ganal",
		"buy": 1,
		"sell": 5,
		"rep": "A",
		"patrol": "A",
		"move": 4,
	},
	{
		"type": "Cargo",
		"to": "Bord",
		"buy": 1,
		"sell": 5,
		"rep": "B",
		"patrol": "B",
		"move": 4,
	},
	{
		"type": "Cargo",
		"to": "Haryl",
		"buy": 1,
		"sell": 5,
		"rep": "C",
		"patrol": "C",
		"move": 4,
	},
	{
		"type": "Cargo",
		"to": "Damon",
		"buy": 1,
		"sell": 5,
		"rep": "D",
		"patrol": "D",
		"move": 4,
	},
	{
		"type": "Cargo",
		"to": "Katak",
		"buy": 1,
		"sell": 6,
		"patrol": "A",
		"move": 3,
	},
	{
		"type": "Cargo",
		"trait": "Illegal",
		"to": "Acan",
		"buy": 2,
		"sell": 7,
		"fame": 1
	},
	{
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
		"type": "Cargo/Mod",
		"trait": "Smuggling Compartment",
		"description": "+1 Cargo\nDeliver Illegal Cargo: Blank to Hit",
		"buy": 2,
	},
]
var _target = null

var player = {
	"bought": false,
	"skipped": false,
	"money": 4000,
	"discount": 0,
	"space": {
		"name": "Acan",
	},
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
}


func _ready():
	randomize()
	_deck.shuffle()
	update_view()

func front():
	return _deck.front()

func update_view():
	var card = _deck.front()
	if card.has("trait") and card.trait == "Illegal":
		$"%Trait".show()
		$"%RollContainer".show()
		$"%FailContainer".show()
	else:
		$"%Trait".hide()
		$"%RollContainer".hide()
		$"%FailContainer".hide()
	if card.has("trait") and card.trait == "Smuggling Compartment":
		$"%Cargo".hide()
		$"%CargoMod".show()
		$"%BuffContainer".show()
		$"%BuffContainer2".show()
	else:
		$"%Cargo".show()
		$"%CargoMod".hide()
		$"%BuffContainer".hide()
		$"%BuffContainer2".hide()
	$"%BuyLabel".text = str(card.buy) + "K"
	if card.has("to"):
		$"%ToContainer".show()
		$"%To".text = card.to
	else:
		$"%ToContainer".hide()
	if card.has("sell"):
		$"%SuccessContainer".show()
		$"%Sell".text = str(card.sell) + "K"
	else:
		$"%SuccessContainer".hide()
	if card.has("rep"):
		$"%Rep".show()
		$"%A".hide()
		$"%B".hide()
		$"%C".hide()
		$"%D".hide()
		get_node("%" + card.rep).show()
	else:
		$"%Rep".hide()
	if card.has("fame"):
		$"%Fame".show()
	else:
		$"%Fame".hide()
	update_buy()
	update_skip()

func update_buy():
	var card = _deck.front()
	var buy = max(0, card.buy - player.discount)
	$"%Buy".text = str(buy) + "K"
	$"%Buy".disabled = false
	if player.bought:
		$"%Buy".disabled = true
		return
	if player.money < buy:
		$"%Buy".disabled = true
		return
	if card.has("to") and player.space.name == card.to:
		$"%Buy".disabled = true
		return
	update_target()
	if _target == null:
		$"%Buy".disabled = true
	
func update_skip():
	$"%Skip".disabled = player.skipped

func update_target():
	for slot in player.cargo_slots:
		if not slot.visible:
			continue
		if not slot.empty and not slot.bartering:
			continue
		_target = slot
		break

func pop_front():
	var card = _deck.pop_front()
	update_view()
	return card

func append(card):
	_deck.append(card)

func _on_buy_pressed():
	emit_signal("bought", pop_front(), _target, self)

func _on_skip_pressed():
	emit_signal("skipped")
	_deck.append(pop_front())
