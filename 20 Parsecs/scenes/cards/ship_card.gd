extends VBoxContainer

var card = {
	"buy": 20,
	"name": "Freighter3",
	"speed": 7,
	"attack": 4,
	"armor": 5,
	"cargo": 1,
	"cargomod": 1,
	"mod": 1,
	"crew": 3,
}

func update_view():
	if card.has("used"):
		$"%Used".show()
		$"%Data".hide()
		return
	$"%Used".hide()
	$"%Data".show()
	$"%BuyLabel".text = str(card.buy) + "K"
	$"%Speed".text = str(card.speed)
	$"%Attack".text = str(card.attack)
	$"%Armor".text = str(card.armor)
	$"%Cargo".text = str(card.cargo)
	if card.has("cargomod"):
		$"%CargoModContainer".show()
		$"%CargoMod".text = str(card.cargomod)
	else:
		$"%CargoModContainer".hide()
	if card.has("mod"):
		$"%ModContainer".show()
		$"%Mod".text = str(card.mod)
	else:
		$"%ModContainer".hide()
	$"%Crew".text = str(card.crew)
