extends VBoxContainer

signal helped

var card = {
	"type": "Cargo",
	"to": "Ganal",
	"buy": 1,
	"sell": 5,
	"rep": "A",
	"patrol": "A",
	"move": 4,
}

func update_view():
	if card.has("trait") and card.trait == "Holotable":
		$"%Holotable".show()
	else:
		$"%Holotable".hide()
	if card.has("trait") and card.trait == "Illegal":
		$"%Trait".show()
		$"%RollContainer".show()
		$"%FailContainer".show()
	else:
		$"%Trait".hide()
		$"%RollContainer".hide()
		$"%FailContainer".hide()
	if card.has("trait") and card.trait == "Smuggling Compartment":
		$"%Cargo".hide()
		$"%CargoMod".show()
		$"%BuffContainer".show()
		$"%BuffContainer2".show()
	else:
		$"%Cargo".show()
		$"%CargoMod".hide()
		$"%BuffContainer".hide()
		$"%BuffContainer2".hide()
	$"%BuyLabel".text = str(card.buy) + "K"
	if card.has("to"):
		$"%ToContainer".show()
		$"%To".text = card.to
	else:
		$"%ToContainer".hide()
	if card.has("sell"):
		$"%SuccessContainer".show()
		if card.sell > 0:
			$"%Sell".show()
			$"%Sell".text = str(card.sell) + "K"
		else:
			$"%Sell".hide()
	else:
		$"%SuccessContainer".hide()
	if card.has("rep"):
		$"%Rep".show()
		$"%A".hide()
		$"%B".hide()
		$"%C".hide()
		$"%D".hide()
		get_node("%" + card.rep).show()
	else:
		$"%Rep".hide()
	if card.has("fame"):
		$"%Fame".show()
		$"%FameLabel".text = str(card.fame)
	else:
		$"%Fame".hide()

func _on_help_pressed():
	var reps = {
		"A": "Ahut",
		"B": "Basyn",
		"C": "Clot",
		"D": "Dreb",
	}
	var text = ""
	if card.has("trait") and card.trait == "Illegal":
		text += "Illegal "
	text += card.type + "\n"
	if $"%Holotable".visible:
		text += "As long as you have at least 2 crews, gain 1 fame"
	if card.has("trait") and card.trait == "Smuggling Compartment":
		text += "Gain an extra cargo slot. When delivering illegal cargo, if you roll blank, you successfully deliver the cargo"
	if card.has("to"):
		text += "Deliver it to " + card.to + " to gain "
	if card.has("fame"):
		text += str(card.fame) + " fame, "
		if not card.has("rep"):
			text += " and "
	if card.has("sell"):
		text += str(card.sell) + "K"
	if card.has("rep"):
		text += " and 1 " + reps[card.rep] + " reputation"
	text += "."
	if card.has("trait") and card.trait == "Illegal":
		text += " To succesfully deliver it, roll a hit. Otherwise face a random encounter."
	emit_signal("helped", text)
