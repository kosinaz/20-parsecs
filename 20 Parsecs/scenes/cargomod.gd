extends TextureRect

var _data = {}
var is_empty = true
var is_ship_cargo = true
var is_ship_mod = true
var is_mod = true
var is_gear = false
var is_cargo = true
var is_market = false
var movement_target = null
var moveable = true

func setup(data):
	clear()
	is_empty = false
	_data = data
	$Data.text = ""
	if has_node("Drop"):
		$Drop.show()
	if has_node("Barter"):
		$Barter.show()
	if has_node("Move"):
		$Move.show()
	if data.has("type"):
		is_mod = true
		is_cargo = false
		$Data.text += data.type + "\n"
		if data.name == "shield upgrade":
			$Recover.show()
		$Data.text += "Price: " + str(_data.buy) + "K\n"
		$Data.text += data.description
	else:
		is_cargo = true
		is_mod = false
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
	
func get_name():
	if not is_empty and _data.has("name"):
		return _data.name
	return ""

func get_price():
	return _data.buy

func is_bartering():
	return $Barter.pressed

func clear():
	movement_target = null
	is_empty = true
	_data = {}
	$Data.text = ""
	if has_node("Deliver"):
		$Deliver.hide()
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
	is_cargo = true
	
func get_to():
	if _data == {} or not _data.has("to"):
		return ""
	return _data.to

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
		get_node(button).disabled = false
		
func disable_button(button):
	if has_node(button):
		get_node(button).disabled = true
