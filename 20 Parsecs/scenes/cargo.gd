extends TextureRect

var _data = {}
var has_cargo = false

func setup(data):
	has_cargo = true
	_data = data
	if has_node("Buy"):
		$Buy.text = "Buy " + str(data.buy) + "K"
	$Data.text = ""
	if data.has("smuggling compartment"):
		$Data.text += "Smuggling\nCompartment\n+25% success"
		return
	if data.has("illegal"):
		$Data.text += "Illegal\n"
	$Data.text += "To " + data.to + ": "
	$Data.text += str(data.sell) + "K "
	if data.has("rep"):
		$Data.text += "1" + data.rep.left(1) + "R "
	if data.has("fame"):
		$Data.text += str(data.fame) + "F "
	if data.has("patrol") and has_node("Buy"):
		$Data.text += "\nPatrol: " + str(data.move) + data.patrol.left(1)

func get_data():
	return _data

func clear():
	has_cargo = false
	_data = {}
	$Data.text = ""
	
func get_to():
	if _data == {} or not _data.has("to"):
		return ""
	return _data.to

func enable_buy():
	$Buy.disabled = false
	
func disable_buy():
	$Buy.disabled = true

func enable_skip():
	$Skip.disabled = false

func disable_skip():
	$Skip.disabled = true

func enable_deliver():
	$Deliver.disabled = false
	
func disable_deliver():
	$Deliver.disabled = true

func enable_drop():
	$Drop.disabled = false

func disable_drop():
	$Drop.disabled = true
