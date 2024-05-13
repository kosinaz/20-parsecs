extends MarginContainer

var _data = {}
var _damage = 0
var defeated = false

func setup(data):
	_data = data
	$"%Label".text = str(_data.name) + "\n"
	$"%Label".text += "Attack: " + str(_data.attack) + "\n"
	$"%Label".text += "Armor: " + str(_data.armor) + "\n"
	$"%Label".text += "Skill: " + str(_data.skill1) + "\n"
	if _data.has("skill2"):
		$"%Label".text += "Skill: " + str(_data.skill2) + "\n"
	if _data.has("skill3"):
		$"%Label".text += "Skill: " + str(_data.skill3) + "\n"
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

func heal(amount = 0):
	defeated = false
	if amount == 0:
		amount = _damage
	_damage -= amount
	setup(_data)
