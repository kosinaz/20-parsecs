extends TextureRect

signal delivered
signal dropped
signal killed
signal helped

var player = {
	"space": {
		"name": "Acan",
	},
}

var empty = true
var captured = false
var bartering = false
	
func set_player(player_to_set):
	player = player_to_set

func get_card():
	if $"%BountyCard".visible:
		return $"%BountyCard".card
	return $"%JobCard".card

func has_bounty(bounty_name = "any"):
	if empty:
		return false
	if not $"%BountyCard".visible:
		return false
	return $"%BountyCard".card.name == bounty_name or bounty_name == "any"
	
func get_bounty_name():
	if empty:
		return "none"
	if not $"%BountyCard".visible:
		return "none"
	return $"%BountyCard".card.name
	
	
func get_to():
	if empty:
		return null
	if not $"%JobCard".visible:
		return null
	return $"%JobCard".card.to

func get_negative_rep_name():
	var rep = $"%BountyCard".card.negative_rep
	if rep == "A":
		return "Ahut"
	if rep == "B":
		return "Basyn"
	if rep == "C":
		return "Cimp"
	if rep == "D":
		return "Dreb"

func get_positive_rep_name():
	var rep = ""
	if $"%BountyCard".visible:
		rep = $"%BountyCard".card.positive_rep
	else:
		rep = $"%JobCard".card.positive_rep
	if rep == "A":
		return "Ahut"
	if rep == "B":
		return "Basyn"
	if rep == "C":
		return "Cimp"
	if rep == "D":
		return "Dreb"

func set_card(card_to_set):
	empty = false
	if card_to_set.deck == "BountyDeck":
		$"%BountyCard".card = card_to_set
		$"%BountyCard".show()
		$"%BountyCard".update_view()
	else:
		$"%JobCard".card = card_to_set
		$"%JobCard".show()
		$"%JobCard".update_view()
	$"%Buttons".show()
	update_buttons()
	
func capture():
	captured = true
	$"%BountyCard".captured = true
	$"%BountyCard".update_view()
	update_buttons()

func remove_card():
	empty = true
	captured = false
	$"%BountyCard".captured = false
	$"%BountyCard".card = null
	$"%BountyCard".hide()
	$"%JobCard".card = null
	$"%JobCard".hide()
	$"%Buttons".hide()

func update_buttons():
	if empty:
		return
	update_deliver()
	update_kill()

func disable_buttons():
	$"%Deliver".disabled = true
	$"%Kill".disabled = true

func update_deliver():
	if captured:
		$"%Deliver".show()
		$"%Deliver".disabled = player.space_name != $"%BountyCard".card.to
	else:
		$"%Deliver".hide()

func update_kill():
	if captured:
		$"%Kill".show()
		$"%Kill".disabled = false
	else:
		$"%Kill".hide()

func has_trait(_trait):
	return false

func _on_deliver_pressed():
	emit_signal("delivered", self)

func _on_drop_pressed():
	emit_signal("dropped", self)

func _on_kill_pressed():
	emit_signal("killed", self)

func _on_help_pressed(text):
	emit_signal("helped", text)
