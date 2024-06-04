extends VBoxContainer

signal helped

var card = {
	"deck": "BountyDeck",
	"level": 1,
	"name": "Nad",
	"attack": 3,
	"attack_type": "GroundAttack",
	"kill_reward": 6,
	"kill_fame": 1,
	"to": "Ekes",
	"deliver_reward": 8,
	"deliver_fame": 2,
	"negative_rep": "C",
	"positive_rep": "D",
	"patrol": "C",
	"move": 4,
}

var captured = false

func _ready():
	update_view()

func update_view():
	$"%Contact".visible = not captured
	$"%Level".texture = load("res://images/person" + str(card.level) + ".png")
	$"%Name".text = card.name
	$"%Attack".text = str(card.attack)
	$"%GroundAttack".hide()
	$"%ShipAttack".hide()
	get_node("%" + card.attack_type).show()
	$"%KillReward".text = str(card.kill_reward) + "K"
	$"%KillFame".text = str(card.kill_fame)
	$"%To".text = card.to
	$"%DeliverReward".text = str(card.deliver_reward) + "K"
	$"%DeliverFame".text = str(card.deliver_fame)
	if card.has("negative_rep"):
		$"%KillRep".show()
		$"%DeliverRep2".show()
		$"%KillRepIcon".texture = load("res://images/patrol-" + (card.negative_rep.to_lower()) + "-icon.png")
		$"%DeliverRep2Icon".texture = load("res://images/patrol-" + (card.negative_rep.to_lower()) + "-icon.png")
	else:
		$"%KillRep".hide()
		$"%DeliverRep2".hide()
	if card.has("positive_rep"):
		$"%DeliverRep1".show()
		$"%DeliverRep1Icon".texture = load("res://images/patrol-" + (card.positive_rep.to_lower()) + "-icon.png")
	else:
		$"%DeliverRep1".hide()

func _on_help_pressed():
	var reps = {
		"A": "Ahut",
		"B": "Basyn",
		"C": "Clot",
		"D": "Dreb",
	}
	var text = "Bounty\nFind " + card.name
	text += "! He is a level " + str(card.level)
	text += " contact. He has " + str(card.attack)
	if $"%GroundAttack".visible:
		text += " ground attack. "
	else:
		text += " ship attack. "
	text += "Eliminate him and gain " + str(card.kill_reward) + "K, "
	text += str(card.kill_fame) + " fame"
	if $"%KillRep".visible:
		text += ", and -1 " + reps[card.negative_rep] + " reputation"
	text += ". "
	text += "Or deliver him to " + card.to
	text += ", and gain " + str(card.deliver_reward) + "K, "
	text += str(card.deliver_fame) + " fame"
	if $"%DeliverRep1".visible:
		text += ", 1 " + reps[card.positive_rep] + " reputation"
	if $"%DeliverRep2".visible:
		text += ", and -1 " + reps[card.negative_rep] + " reputation"
	text += "."
	emit_signal("helped", text)
