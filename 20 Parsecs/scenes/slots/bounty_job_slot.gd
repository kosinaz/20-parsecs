extends TextureRect

signal delivered
signal dropped

var player = {
	"space": {
		"name": "Acan",
	},
}

var empty = true
var caught = false
var bartering = false
	
func set_player(player_to_set):
	player = player_to_set

func get_card():
	return $"%BountyCard".card

func set_card(card_to_set):
	empty = false
	$"%BountyCard".card = card_to_set
	$"%BountyCard".show()
	$"%BountyCard".update_view()
	$"%Buttons".show()
	update_buttons()

func remove_card():
	empty = true
	caught = false
	$"%BountyCard".card = null
	$"%BountyCard".hide()
	$"%Buttons".hide()

func update_buttons():
	if empty:
		return
	update_deliver()

func disable_buttons():
	$"%Deliver".disabled = true

func update_deliver():
	if caught:
		$"%Deliver".show()
		$"%Deliver".disabled = player.space_name != $"%BountyCard".card.to
	else:
		$"%Deliver".hide()

func has_trait(_trait):
	return false

func _on_deliver_pressed():
	emit_signal("delivered", self)

func _on_drop_pressed():
	emit_signal("dropped", self)
