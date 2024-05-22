extends VBoxContainer

var card = {
	"type": "Gear",
	"trait": "Armor",
	"buy": 3,
	"name": "armored vest",
	"patrol": "C",
	"move": 3,
}

var armor = false

func _ready():
	update_view()

func update_view():
	if card.has("trait") and card.trait == "Armor":
		armor = true
		$"%Trait".show()
		$"%Armor".show()
		$"%Info".show()
		$"%ArmorInfo".show()
	else:
		armor = false
		$"%Trait".hide()
		$"%Armor".hide()
		$"%Info".hide()
		$"%ArmorInfo".hide()
	if card.has("attack"):
		$"%Buff".show()
	else:
		$"%Buff".hide()
	$"%Combat".hide()
	if card.name == "vibroknife":
		$"%Combat".show()
		$"%Knife".show()
		$"%KnifeSkill".show()
	else:
		$"%Knife".hide()
		$"%KnifeSkill".hide()
	if card.name == "blaster rifle":
		$"%Combat".show()
		$"%Rifle".show()
	else:
		$"%Rifle".hide()
	if card.name == "vibroax":
		$"%Combat".show()
		$"%Ax".show()
	else:
		$"%Ax".hide()
	if card.name == "jetpack":
		$"%Combat".show()
		$"%Jet".show()
	else:
		$"%Jet".hide()
	if card.name == "plastoid armor":
		$"%Combat".show()
		$"%Plast".show()
	else:
		$"%Plast".hide()
	$"%BuyLabel".text = str(card.buy) + "K"
	if card.has("attack"):
		$"%Attack".show()
		$"%AttackLabel".text = str(card.attack)
	else:
		$"%Attack".hide()
