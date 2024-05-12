extends MarginContainer

var _data = {}
var damage = 0
var money = 0

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
	$"%Label".text += "Damage: " + str(damage) + "\n"
	$"%Label".text += "Money: " + str(money) + ""

func get_data():
	return _data
	
func get_money():
	return money
	
func increase_money(amount):
	money += amount
	setup(_data)
	
func decrease_money(amount):
	money -= amount
	setup(_data)
	
