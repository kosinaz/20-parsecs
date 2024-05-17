extends TextureRect

var _data = {}
var _damage = 0
var defeated = false

func setup(data):
	_data = data
	if data.has("used"):
		$Buy.text = "Buy"
		$Data.text = "Buy any of the more expensive ships, but suffer 3 damage."
		return
	if has_node("Buy"):
		$Buy.text = "Buy " + str(get_reduced_price($"%Ship".get_price())) + "K"
	$Data.text = "Price: " + str(_data.buy) + "K\n"
	$Data.text += "Speed: " + str(_data.speed) + "\n"
	$Data.text += "Attack: " + str(_data.attack) + "\n"
	$Data.text += "Armor: " + str(_data.armor) + "\n"
	$Data.text += "Cargo: " + str(_data.cargo)
	if _data.has("mod"):
		$Data.text += " Mod: " + str(_data.mod)
	if _data.has("cargomod"):
		$Data.text += "\nCargo/Mod: " + str(_data.cargomod)
	$Data.text += "\nCrew: " + str(_data.crew)
	if not has_node("Buy"):
		$"%ShipDamage".value = 0
		update_armor()

func get_data():
	return _data

func get_damage():
	return _damage
	
func get_price():
	if _data and _data.has("buy"):
		return _data.buy
	return 0
	
func get_reduced_price(price):
	return max(get_price() - price, 0)

func damage(amount):
	_damage += amount
	if _damage >= get_armor():
		defeated = true
		_damage = get_armor()
	$"%ShipDamage".value = _damage
	$"%ShipDamageLabel".text = str(get_armor() - _damage) + "/" + str(get_armor())

func repair(amount = 0):
	defeated = false
	if amount == 0:
		amount = _damage
	_damage -= amount
	$"%ShipDamage".value = _damage
	$"%ShipDamageLabel".text = str(get_armor() - _damage) + "/" + str(get_armor())

func get_armor():
	var armor = _data.armor
	if $"%ShipMod".get_name() == "shield upgrade":
		armor += 1
	return armor

func update_armor():
	$"%ShipDamage".max_value = get_armor()
	$"%ShipDamageLabel".text = str(get_armor() - _damage) + "/" + str(get_armor())
	if _damage >= get_armor():
		defeated = true
		_damage = get_armor()

func enable_buy():
	$Buy.disabled = false
	
func disable_buy():
	$Buy.disabled = true

func enable_skip():
	$Skip.disabled = false

func disable_skip():
	$Skip.disabled = true
