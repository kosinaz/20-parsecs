extends VBoxContainer

signal helped

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
	if card.has("reward"):
		$"%Reward".show()
		$"%RewardLabel".text = str(card.reward)
	else:
		$"%Reward".hide()
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

func _on_help_pressed():
	var reps = {
		"A": "Ahut",
		"B": "Basyn",
		"C": "Clot",
		"D": "Dreb",
	}
	var text = "Job\n"
	text += card.name + "\n"
	text += "You will need: " + card.skills[0]
	if card.skills.size() > 1:
		for i in card.skills.size() - 1:
			text += ", " + card.skills[i + 1]
	text += ".\nGo to " + card.to
	text += " and complete the job to gain"
	if card.has("reward"):
		text += " " + str(card.reward) + "K"
	if card.has("fame"):
		if card.has("reward"):
			if not card.has("positive_rep") and not card.has("negative_rep"):
				text += " and"
			else:
				text += ", "
		text += " " + str(card.fame) + " fame"
	if card.has("positive_rep"):
		if card.has("reward") or card.has("fame"):
			if not card.has("negative_rep"):
				text += " and"
			else:
				text += ","
		text += " 1 " + reps[card.positive_rep] + " reputation"
	if card.has("negative_rep"):
		text += " and -1 " + reps[card.negative_rep] + " reputation"
	text += "."
	if card.has("overclock_fame"):
		text += " If you already have 1 " + reps[card.positive_rep] + " reputation, lose 1 " + reps[card.overclock_negative_rep] + " reputation instead and gain 1 fame."
	emit_signal("helped", text)
