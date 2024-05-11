extends MarginContainer

var _data = {}

func setup(data):
	_data = data
	$"%Label".text = "To: " + data.to + "\n"
	$"%Label".text += "Buy: " + str(data.buy) + "\n"
	$"%Label".text += "Sell: " + str(data.sell) + "\n"
	$"%Label".text += "Rep: " + data.rep + "\n"
	$"%Label".text += "Patrol: " + data.patrol + "\n"
	$"%Label".text += "Move: " + str(data.move)

func get_data():
	return _data

func clear():
	_data = {}
	$"%Label".text = ""
