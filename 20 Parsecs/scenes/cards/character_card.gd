extends VBoxContainer

var card = {
	"name": "San",
	"attack": 3,
	"armor": 4,
	'skills': ["Piloting", "Tactics"]
}

func update_view():
	$"%Attack".text = str(card.attack)
	$"%Armor".text = str(card.armor)

