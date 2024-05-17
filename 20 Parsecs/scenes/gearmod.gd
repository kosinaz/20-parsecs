extends TextureRect

var _data = {}
var is_empty = true
var is_ship_cargo = false
export var is_ship_mod = false
var is_mod = true
var is_gear = true
var is_cargo = false
var is_market = false
var movement_target = null

func setup(data):
	clear()
	is_empty = false
	_data = data
	if has_node("Drop"):
		$Drop.show()
	if has_node("Barter"):
		$Barter.show()
	if has_node("Move"):
		$Move.show()
	if data.has("smuggling compartment"):
		is_cargo = true
		is_mod = true
		is_gear = false
		$Data.text = "Cargo/Mod\nPrice: 2K\nSmuggling\nCompartment\n+25% success\n+1 Cargo"
		return
	$Data.text = data.type + "\n"
	if data.type == "Mod":
		is_mod = true
		is_gear = false
	if data.type == "Gear":
		is_mod = false
		is_gear = true
	if has_node("Buy"):
		is_market = true
		$Buy.text = "Buy " + str(data.buy) + "K"
	elif data.name == "shield upgrade":
		$Recover.show()
	$Data.text += "Price: " + str(_data.buy) + "K\n"
	$Data.text += data.description
	if data.has("patrol") and has_node("Buy"):
		$Data.text += "\nPatrol: " + str(data.move) + data.patrol

func get_data():
	return _data
	
func get_name():
	if not is_empty and _data.has("name"):
		return _data.name
	return ""

func is_bartering():
	return $Barter.pressed
	
func clear():
	movement_target = null
	is_empty = true
	_data = {}
	$Data.text = ""
	if has_node("Recover"):
		$Recover.hide()
	if has_node("Drop"):
		$Drop.hide()
	if has_node("Barter"):
		$Barter.hide()
		$Barter.pressed = false
	if has_node("Move"):
		$Move.hide()
	is_mod = true
	is_gear = true

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

func enable_recover():
	$Recover.disabled = false

func disable_recover():
	$Recover.disabled = true

func enable_move():
	$Move.disabled = false

func disable_move():
	$Move.disabled = true
