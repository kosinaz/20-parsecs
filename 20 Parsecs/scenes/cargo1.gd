extends Label

var _data = {}
var has_cargo = false

func setup(data):
	has_cargo = true
	_data = data
	text = ""
	if data.has("smuggling compartment"):
		text += "Smuggling\nCompartment\n+25% success"
		return
	if data.has("illegal"):
		text += "Illegal\n"
	text += "To " + data.to + ": "
	text += str(data.sell) + "K "
	if data.has("rep"):
		text += "1" + data.rep.left(1) + "R "
	if data.has("fame"):
		text += str(data.fame) + "F "
	if data.has("patrol"):
		text += "\nPatrol: " + str(data.move) + data.patrol.left(1)

func get_data():
	return _data

func clear():
	has_cargo = false
	_data = {}
	text = ""
	
func get_to():
	if _data == {} or not _data.has("to"):
		return ""
	return _data.to
