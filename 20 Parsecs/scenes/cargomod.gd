extends TextureRect

var _data = {}
var has_cargo = false

func setup(data):
	clear()
	has_cargo = true
	_data = data
	$Data.text = ""
	if has_node("Drop"):
		$Drop.show()
	if has_node("Barter"):
		$Barter.show()
	if has_node("Move"):
		$Move.show()
	if data.has("type"):
		$Data.text += data.type + "\n"
		if data.name == "shield upgrade":
			$Recover.show()
		$Data.text += "Price: " + str(_data.buy) + "K\n"
		$Data.text += data.description
	else:
		if data.has("smuggling compartment"):
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
	if has_cargo and _data.has("name"):
		return _data.name
	return ""

func clear():
	has_cargo = false
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
	
func get_to():
	if _data == {} or not _data.has("to"):
		return ""
	return _data.to

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

func enable_recover():
	$Recover.disabled = false

func disable_recover():
	$Recover.disabled = true

func enable_move():
	$Move.disabled = false

func disable_move():
	$Move.disabled = true
