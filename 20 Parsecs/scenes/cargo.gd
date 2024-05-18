extends TextureRect

var _data = {}
var is_empty = true
export var is_ship_cargo = false
var is_ship_mod = false
var is_cargo = true
var is_mod = false
var is_gear = false
var is_market = false
var is_free = false
var movement_target = null
var moveable = true

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

func get_price():
	return _data.buy

func set_buy_text(text):
	$Buy.text = text

func enable_buttons():
	for child in get_children():
		if child is Button:
			child.disabled = false
	
func disable_buttons():
	for child in get_children():
		if child is Button:
			child.disabled = true

func enable_button(button):
	if has_node(button):
		get_node(button).disabled = true
		
func disable_button(button):
	if has_node(button):
		get_node(button).disabled = true
