extends MarginContainer

var _data = {}

func setup(data):
	_data = data
	$"%Label".text = ""
	if data.has("illegal"):
		$"%Label".text += "Illegal\n"
	$"%Label".text += "To: " + data.to + "\n"
	$"%Label".text += "Buy: " + str(data.buy) + "\n"
	$"%Label".text += "Sell: " + str(data.sell) + "\n"
	if data.has("rep"):
		$"%Label".text += "Rep: " + data.rep + "\n"
	if data.has("fame"):
		$"%Label".text += "Fame: " + str(data.fame) + "\n"
	$"%Label".text += "Patrol: " + data.patrol + "\n"
	$"%Label".text += "Move: " + str(data.move)

func get_data():
	return _data

func clear():
	_data = {}
	$"%Label".text = ""
	
func get_to():
	if _data == {} or not _data.has("to"):
		return ""
	return _data.to
