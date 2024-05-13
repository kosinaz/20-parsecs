extends MarginContainer

var _data = {}
var _damage = 0
var defeated = false

func setup(data):
	_data = data
	$"%Label".text = "Buy: " + str(_data.buy) + "\n"
	$"%Label".text += "Speed: " + str(_data.speed) + "\n"
	$"%Label".text += "Attack: " + str(_data.attack) + "\n"
	$"%Label".text += "Armor: " + str(_data.armor) + "\n"
	$"%Label".text += "Damage: " + str(_damage)

func get_data():
	return _data

func get_damage():
	return _damage

func damage(amount):
	_damage += amount
	if _damage >= _data.armor:
		defeated = true
		_damage = _data.armor
	setup(_data)

func repair(amount = 0):
	defeated = false
	if amount == 0:
		amount = _damage
	_damage -= amount
	setup(_data)

