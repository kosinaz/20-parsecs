extends TextureRect

signal took
signal skipped

var _deck = [
	{
		"deck": "JobDeck",
		"name": "Ahut Favor",
		"skills": ["influence"],
		"to": "Bord",
		"reward": 5,
		"positive_rep": "A",
		"overclock_negative_rep": "B",
		"overclock_fame": 1,
		"patrol": "A",
		"move": 4,
	},
	{
		"deck": "JobDeck",
		"name": "Basyn Favor",
		"skills": ["knowledge"],
		"to": "Ganal",
		"reward": 5,
		"positive_rep": "B",
		"overclock_negative_rep": "A",
		"overclock_fame": 1,
		"patrol": "B",
		"move": 4,
	},
	{
		"deck": "JobDeck",
		"name": "Cimp Favor",
		"skills": ["tactics"],
		"to": "Haryl",
		"reward": 5,
		"positive_rep": "C",
		"overclock_negative_rep": "D",
		"overclock_fame": 1,
		"patrol": "C",
		"move": 4,
	},
	{
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
	},
	{
		"deck": "JobDeck",
		"name": "Ekes Run",
		"skills": ["influence", "strength", "tactics", "knowledge", "piloting"],
		"to": "Ekes",
		"reward": 10,
		"fame": 2,
		"patrol": "D",
		"move": 3,
	},
	{
		"deck": "JobDeck",
		"name": "Jewel Heist",
		"skills": ["knowledge", "tactics", "influence", "stealth", "strength"],
		"to": "Inab",
		"reward": 15,
		"fame": 1,
		"patrol": "C",
		"move": 3,
	},
	{
		"deck": "JobDeck",
		"name": "Casino Heist",
		"skills": ["influence", "tech", "strength"],
		"to": "Acan",
		"reward": 15,
		"patrol": "D",
		"move": 3,
	},
	{
		"deck": "JobDeck",
		"name": "Mine Rescue",
		"skills": ["knowledge", "stealth", "strength"],
		"to": "Ekes",
		"reward": 8,
		"fame": 1,
		"negative_rep": "B",
		"patrol": "B",
		"move": 3,
	},
	{
		"deck": "JobDeck",
		"name": "Freighter Hijack",
		"skills": ["knowledge", "stealth", "strength"],
		"to": "Jakaf",
		"reward": 5,
		"fame": 2,
		"positive_rep": "A",
		"patrol": "B",
		"move": 3,
	},
	{
		"deck": "JobDeck",
		"name": "Spy Hunt",
		"skills": ["influence", "knowledge", "tactics"],
		"to": "Katak",
		"reward": 5,
		"fame": 1,
		"patrol": "A",
		"move": 3,
	},
	{
		"deck": "JobDeck",
		"name": "Temple Raid",
		"skills": ["knowledge", "stealth", "tactics"],
		"to": "Damon",
		"reward": 5,
		"fame": 1,
		"patrol": "C",
		"move": 3,
	},
	{
		"deck": "JobDeck",
		"name": "Stash Raid",
		"skills": ["piloting", "stealth", "knowledge", "tech"],
		"to": "Fatat",
		"reward": 10,
		"fame": 1,
		"negative_rep": "A",
		"patrol": "A",
		"move": 3,
	},
]
var _target = null

var player = {
	"bought": false,
	"skipped": false,
	"space_name": "Acan",
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
	$"%JobCard".card = card
	$"%JobCard".update_view()
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
	if player.space_name == $"%JobCard".card.to:
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
