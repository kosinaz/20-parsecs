extends MarginContainer

var _data = {}
var damage = 0

func setup(data):
	_data = data
	$"%Label".text = "Buy: " + str(_data.buy) + "\n"
	$"%Label".text += "Speed: " + str(_data.speed) + "\n"
	$"%Label".text += "Attack: " + str(_data.attack) + "\n"
	$"%Label".text += "Armor: " + str(_data.armor) + "\n"
	$"%Label".text += "Damage: 0"

func get_data():
	return _data
