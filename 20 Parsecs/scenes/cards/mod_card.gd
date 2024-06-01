extends VBoxContainer

var card = {
	"type": "Mod",
	"buy": 2,
	"name": "quad laser",
	"attack": 1,
	"patrol": "C",
	"move": 3,
}

func _ready():
	update_view()

func update_view():
	$"%Buff".hide()
	if card.has("attack"):
		$"%Buff".show()
		$"%Attack".show()
	else:
		$"%Attack".hide()
	if card.has("armor"):
		$"%Buff".show()
		$"%Armor".show()
	else:
		$"%Armor".hide()
	if card.has("speed"):
		$"%Buff".show()
		$"%Speed".show()
	else:
		$"%Speed".hide()
	if card.name == "shield upgrade":
		$"%Shield".show()
	else:
		$"%Shield".hide()
	$"%Combat".hide()
	if card.name == "targeting computer":
		$"%Combat".show()
		$"%Computer".show()
	else:
		$"%Computer".hide()
	if card.name == "maneuvering thrusters":
		$"%Combat".show()
		$"%Thruster".show()
	else:
		$"%Thruster".hide()
	$"%Torpedo".hide()
	if card.name == "torpedo":
		$"%Torpedo".show()
		$"%Patrol".show()
	if card.name == "chrome":
		$"%Torpedo".show()
		$"%Patrol".hide()
	if card.name == "ion cannon":
		$"%Combat".show()
		$"%Cannon".show()
	else:
		$"%Cannon".hide()
	if card.name == "autoblaster":
		$"%Combat".show()
		$"%Blaster".show()
	else:
		$"%Blaster".hide()
	$"%BuyLabel".text = str(card.buy) + "K"
