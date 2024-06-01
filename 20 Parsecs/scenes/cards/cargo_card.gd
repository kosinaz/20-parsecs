extends VBoxContainer

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
