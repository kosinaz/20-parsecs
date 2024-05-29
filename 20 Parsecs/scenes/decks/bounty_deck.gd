extends TextureRect

signal took
signal skipped

var _deck = [
	{
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
	},
	{
		"deck": "BountyDeck",
		"level": 2,
		"name": "Keh",
		"attack": 3,
		"attack_type": "ShipAttack",
		"kill_reward": 6,
		"kill_fame": 1,
		"to": "Ganal",
		"deliver_reward": 8,
		"deliver_fame": 2,
	},
	{
		"deck": "BountyDeck",
		"level": 2,
		"name": "Ode",
		"attack": 4,
		"attack_type": "GroundAttack",
		"kill_reward": 8,
		"kill_fame": 1,
		"to": "Bord",
		"deliver_reward": 9,
		"deliver_fame": 2,
		"negative_rep": "A",
		"positive_rep": "B",
		"patrol": "A",
		"move": 4,
	},
	{
		"deck": "BountyDeck",
		"level": 2,
		"name": "Mol",
		"attack": 4,
		"attack_type": "GroundAttack",
		"kill_reward": 8,
		"kill_fame": 1,
		"to": "Fatat",
		"deliver_reward": 10,
		"deliver_fame": 2,
		"patrol": "C",
		"move": 3,
	},
	{
		"deck": "BountyDeck",
		"level": 3,
		"name": "Ata",
		"attack": 5,
		"attack_type": "GroundAttack",
		"kill_reward": 5,
		"kill_fame": 2,
		"to": "Inab",
		"deliver_reward": 15,
		"deliver_fame": 2,
	},
	{
		"deck": "BountyDeck",
		"level": 3,
		"name": "All",
		"attack": 5,
		"attack_type": "ShipAttack",
		"kill_reward": 6,
		"kill_fame": 2,
		"to": "Clot",
		"deliver_reward": 15,
		"deliver_fame": 2,
		"negative_rep": "D",
		"positive_rep": "C",
		"patrol": "C",
		"move": 3,
	},
	{
		"deck": "BountyDeck",
		"level": 3,
		"name": "Jom",
		"attack": 5,
		"attack_type": "GroundAttack",
		"kill_reward": 6,
		"kill_fame": 2,
		"to": "Jakaf",
		"deliver_reward": 16,
		"deliver_fame": 2,
		"negative_rep": "B",
		"patrol": "B",
		"move": 4,
	},
	{
		"deck": "BountyDeck",
		"level": 3,
		"name": "Acc",
		"attack": 6,
		"attack_type": "GroundAttack",
		"kill_reward": 8,
		"kill_fame": 2,
		"to": "Jakaf",
		"deliver_reward": 18,
		"deliver_fame": 2,
	},
	{
		"deck": "BountyDeck",
		"level": 3,
		"name": "Are",
		"attack": 6,
		"attack_type": "GroundAttack",
		"kill_reward": 8,
		"kill_fame": 2,
		"to": "Clot",
		"deliver_reward": 17,
		"deliver_fame": 2,
		"positive_rep": "C",
		"patrol": "D",
		"move": 4,
	},
]
var _target = null

var player = {
	"bought": false,
	"skipped": false,
	"bounty_job_slots": [
		{
			"empty": true,
		},
		{
			"empty": true,
		},
	],
}

func _ready():
	randomize()
	_deck.shuffle()
	update_view()
	
func set_player(player_to_set):
	player = player_to_set
	update_view()

func update_view():
	var card = _deck.front()
	if card == null:
		$"%BountyCard".card = null
		$"%BountyCard".hide()
		$"%Buttons".hide()
		return
	$"%BountyCard".card = card
	$"%BountyCard".update_view()
	update_buttons()

func update_buttons():
	update_take()
	update_skip()
	
func disable_buttons():
	$"%Take".disabled = true
	$"%Skip".disabled = true

func update_take():
	$"%Take".disabled = false
	if player.bought:
		$"%Take".disabled = true
		return
	update_target()
	if _target == null:
		$"%Take".disabled = true
	
func update_skip():
	if player.bought:
		$"%Skip".disabled = true
		return
	$"%Skip".disabled = player.skipped

func update_target():
	_target = null
	if player.bounty_job_slots[0].empty:
		_target = player.bounty_job_slots[0]
	elif player.bounty_job_slots[1].empty:
		_target = player.bounty_job_slots[1]

func front():
	return _deck.front()

func pop_front():
	var card = _deck.pop_front()
	update_view()
	return card

func append(card):
	_deck.append(card)

func _on_take_pressed():
	var target = _target
	var card = pop_front()
	emit_signal("took", card, target)

func _on_skip_pressed():
	emit_signal("skipped")
	append(pop_front())
