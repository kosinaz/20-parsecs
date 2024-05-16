extends TextureRect

var _data = {}
var has_mod = false

func setup(data):
	has_mod = true
	_data = data
	$Data.text = data.type + "\n"
	if has_node("Buy"):
		$Buy.text = "Buy " + str(data.buy) + "K"
	$Data.text += "Price: " + str(_data.buy) + "K\n"
	$Data.text += data.description
	if data.has("patrol") and has_node("Buy"):
		$Data.text += "\nPatrol: " + str(data.move) + data.patrol

func get_data():
	return _data
	
func get_name():
	if has_mod:
		return _data.name
	return ""

func clear():
	has_mod = false
	_data = {}
	$Data.text = ""
	if has_node("Barter"):
		$Barter.pressed = false

func enable_buy():
	$Buy.disabled = false
	
func disable_buy():
	$Buy.disabled = true

func enable_skip():
	$Skip.disabled = false

func disable_skip():
	$Skip.disabled = true

func enable_drop():
	$Drop.disabled = false

func disable_drop():
	$Drop.disabled = true

func enable_barter():
	$Barter.disabled = false

func disable_barter():
	$Barter.disabled = true
