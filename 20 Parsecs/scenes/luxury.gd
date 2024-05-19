extends TextureRect

var _data = {}
var is_empty = true
var is_ship_cargo = false
var is_ship_mod = false
var is_mod = false
var is_gear = false
var is_cargo = false
var is_market = true
var is_free = false
var movement_target = null
var moveable = true

func setup(data):
	clear()
	is_empty = false
	_data = data
	$Data.text = "Luxury, " + data.type
	if data.has("subtype"):
		$Data.text += ", " + data.subtype
	if data.type == "Mod":
		is_mod = true
		is_gear = false
	if data.type == "Gear":
		is_mod = false
		is_gear = true
	if has_node("Buy"):
		is_market = true
		$Buy.text = "\nBuy " + str(data.buy) + "K"
	elif data.name == "shield upgrade":
		$Recover.show()
	$Data.text += "\nPrice: " + str(_data.buy) + "K\n"
	$Data.text += data.description
	if data.has("patrol") and has_node("Buy"):
		$Data.text += "\nPatrol: " + str(data.move) + data.patrol
	$"%Character".update_armor()

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

func is_armor():
	if not is_empty and _data.has("subtype"):
		return true
	return false

func set_buy_text(text):
	$Buy.text = text
	
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
	$"%Character".update_armor()

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
