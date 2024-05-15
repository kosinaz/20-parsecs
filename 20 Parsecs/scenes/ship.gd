extends TextureRect

var _data = {}
var _damage = 0
var defeated = false

func setup(data):
	_data = data
	if has_node("Buy"):
		$Buy.text = "Buy " + str(data.buy) + "K"
	$Data.text = "Speed: " + str(_data.speed) + "\n"
	$Data.text += "Attack: " + str(_data.attack) + "\n"
	$Data.text += "Armor: " + str(_data.armor) + "\n"
	$Data.text += "Cargo: " + str(_data.cargo) + "\n"
	if _data.has("mod"):
		$Data.text += "Mod: " + str(_data.mod) + "\n"
	if _data.has("cargomod"):
		$Data.text += "Cargo/Mod: " + str(_data.cargomod) + "\n"
	$Data.text += "Crew: " + str(_data.crew) + "\n"
	$Data.text += "Damage: " + str(_damage)

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

