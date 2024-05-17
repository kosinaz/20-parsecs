extends TextureRect

var _data = {}
var is_empty = true
export var is_ship_cargo = false
var is_ship_mod = false
var is_cargo = true
var is_mod = false
var is_market = false
var movement_target = null

func setup(data):
	clear()
	is_empty = false
	_data = data
	$Data.text = ""
	if has_node("Buy"):
		is_market = true
		$Buy.text = "Buy " + str(data.buy) + "K"
	if has_node("Drop"):
		$Drop.show()
	if has_node("Barter"):
		$Barter.show()
	if has_node("Move"):
		$Move.show()
	if data.has("smuggling compartment"):
		is_mod = true
		$Data.text += "Cargo/Mod\nPrice: 2K\nSmuggling\nCompartment\n+25% success\n+1 Cargo"
		return
	if has_node("Deliver"):
		$Deliver.show()
	if data.has("illegal"):
		$Data.text += "Illegal\n"
	$Data.text += "Price: " + str(_data.buy) + "K\n"
	$Data.text += "To " + data.to + ": "
	$Data.text += str(data.sell) + "K"
	if data.has("rep"):
		$Data.text += " 1" + data.rep + "R"
	if data.has("fame"):
		$Data.text += " " + str(data.fame) + "F"
	if data.has("patrol") and has_node("Buy"):
		$Data.text += "\nPatrol: " + str(data.move) + data.patrol

func get_data():
	return _data
	
func is_bartering():
	return $Barter.pressed

func clear():
	is_empty = true
	movement_target = null
	_data = {}
	$Data.text = ""
	if has_node("Deliver"):
		$Deliver.hide()
	if has_node("Drop"):
		$Drop.hide()
	if has_node("Barter"):
		$Barter.hide()
		$Barter.pressed = false
	if has_node("Move"):
		$Move.hide()
	is_mod = false
	
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

func enable_barter():
	$Barter.disabled = false

func disable_barter():
	$Barter.disabled = true

func enable_move():
	$Move.disabled = false

func disable_move():
	$Move.disabled = true
