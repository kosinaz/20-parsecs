extends TextureRect

var _data = {}
var _damage = 0
var defeated = false

func setup(data):
	_data = data
	$Data.text = "Name: " + str(_data.name) + "\n"
	$Data.text += "Attack: " + str(_data.attack) + "\n"
	$Data.text += "Armor: " + str(_data.armor) + "\n"
	$Data.text += "Skill: " + str(_data.skill1) + "\n"
	if _data.has("skill2"):
		$Data.text += "Skill: " + str(_data.skill2) + "\n"
	if _data.has("skill3"):
		$Data.text += "Skill: " + str(_data.skill3) + "\n"
	$"%CharacterDamage".value = 0
	update_armor()

func get_data():
	return _data

func get_damage():
	return _damage

func damage(amount):
	_damage += amount
	if _damage >= _data.armor:
		defeated = true
		_damage = _data.armor
	$"%CharacterDamage".value = _damage
	$"%CharacterDamageLabel".text = str(_data.armor - _damage) + "/" + str(_data.armor)

func heal(amount = 0):
	defeated = false
	if amount == 0:
		amount = _damage
	_damage -= amount
	$"%CharacterDamage".value = _damage
	$"%CharacterDamageLabel".text = str(_data.armor - _damage) + "/" + str(_data.armor)

func get_armor():
	if not _data.has("armor"):
		return 4
	var armor = _data.armor
#	if ["armored vest", "plastoid armor"].has($"%CharacterGear".get_name()):
#		armor += 2
#	if ["armored vest", "plastoid armor"].has($"%CharacterGear2".get_name()):
#		armor += 2
	return armor

func update_armor():
	$"%CharacterDamage".max_value = get_armor()
	$"%CharacterDamageLabel".text = str(get_armor() - _damage) + "/" + str(get_armor())
	if _damage >= get_armor():
		defeated = true
		_damage = get_armor()
