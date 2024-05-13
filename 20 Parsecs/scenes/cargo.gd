extends MarginContainer

var _data = {}
var has_cargo = false

func setup(data):
	has_cargo = true
	_data = data
	$"%Label".text = ""
	if data.has("smuggling compartment"):
		$"%Label".text += "Smuggling\nCompartment\n+25% success\nBuy: 2000"
		return
	if data.has("illegal"):
		$"%Label".text += "Illegal\n"
	$"%Label".text += "To: " + data.to + "\n"
	$"%Label".text += "Buy: " + str(data.buy) + "\n"
	$"%Label".text += "Sell: " + str(data.sell) + "\n"
	if data.has("rep"):
		$"%Label".text += "Rep: " + data.rep + "\n"
	if data.has("fame"):
		$"%Label".text += "Fame: " + str(data.fame) + "\n"
	if data.has("patrol"):
		$"%Label".text += "Patrol: " + data.patrol + "\n"
	if data.has("move"):
		$"%Label".text += "Move: " + str(data.move)

func get_data():
	return _data

func clear():
	has_cargo = false
	_data = {}
	$"%Label".text = ""
	
func get_to():
	if _data == {} or not _data.has("to"):
		return ""
	return _data.to
