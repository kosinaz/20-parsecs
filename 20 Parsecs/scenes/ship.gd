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
	$Data.text += "Crew: " + str(_data.crew)
	$"%ShipDamage".value = 0
	$"%ShipDamage".max_value = _data.armor
	$"%ShipDamageLabel".text = str(_data.armor - _damage) + "/" + str(_data.armor)

func get_data():
	return _data

func get_damage():
	return _damage

func damage(amount):
	_damage += amount
	if _damage >= _data.armor:
		defeated = true
		_damage = _data.armor
	$"%ShipDamage".value = _damage
	$"%ShipDamageLabel".text = str(_data.armor - _damage) + "/" + str(_data.armor)

func repair(amount = 0):
	defeated = false
	if amount == 0:
		amount = _damage
	_damage -= amount
	$"%ShipDamage".value = _damage
	$"%ShipDamageLabel".text = str(_data.armor - _damage) + "/" + str(_data.armor)

func enable_buy():
	$Buy.disabled = false
	
func disable_buy():
	$Buy.disabled = true

func enable_skip():
	$Skip.disabled = false

func disable_skip():
	$Skip.disabled = true
