extends VBoxContainer

var card = {
	"deck": "JobDeck",
	"name": "Dreb Favor",
	"skills": ["knowledge"],
	"to": "Clot",
	"reward": 5,
	"positive_rep": "D",
	"overclock_negative_rep": "C",
	"overclock_fame": 1,
	"patrol": "D",
	"move": 4,
}

func _ready():
	update_view()

func update_view():
	$"%Name".text = card.name
	for skill in $"%Skills".get_children():
		if card.skills.has(skill.name.to_lower()):
			skill.show()
		else:
			skill.hide()
	$"%To".text = card.to
	$"%Reward".text = str(card.reward)
	if card.has("fame"):
		$"%Fame".show()
		$"%FameLabel".text = str(card.fame)
	else:
		$"%Fame".hide()
	if card.has("positive_rep"):
		$"%PositiveRep".show()
		$"%PositiveRepTexture".texture = load("res://images/patrol-" + card.positive_rep.to_lower() + "-icon.png")
	else:
		$"%PositiveRep".hide()
	if card.has("negative_rep"):
		$"%NegativeRep".show()
		$"%NegativeRepTexture".texture = load("res://images/patrol-" + card.negative_rep.to_lower() + "-icon.png")
	else:
		$"%NegativeRep".hide()
	if card.has("overclock_fame"):
		$"%Overclock".show()
		$"%OCPositiveRepTexture".texture = load("res://images/positive-rep-" + card.positive_rep.to_lower() + ".png")
		$"%OCNegativeRepTexture".texture = load("res://images/patrol-" + card.overclock_negative_rep.to_lower() + "-icon.png")
	else:
		$"%Overclock".hide()
