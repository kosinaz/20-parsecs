extends TextureRect

signal bartered

var player = {
	"bought": false,
	"gear_slots": [
		{
			"visible": true,
			"empty": true,
			"bartering": false,
		},
		{
			"visible": false,
			"empty": true,
			"bartering": false,
		},
	],
}

var empty = true
var bartering = false
var armor = false
var _target = null
	
func set_player(player_to_set):
	player = player_to_set

func get_card():
	return $"%GearCard".card

func set_card(card_to_set):
	empty = false
	if card_to_set.has("trait") and card_to_set.trait == "Armor":
		armor = true
	else:
		armor = false
	$"%GearCard".card = card_to_set
	$"%GearCard".show()
	$"%GearCard".update_view()
	$"%Buttons".show()
	update_buttons()

func remove_card():
	empty = true
	$"%GearCard".card = null
	$"%GearCard".hide()
	$"%Buttons".hide()
	
func has_trait(trait):
	if empty:
		return false
	if not $"%GearCard".card.has("trait"):
		return false
	return $"%GearCard".card.trait == trait

func update_buttons():
	if empty:
		return
	update_barter()

func disable_buttons():
	$"%Barter".disabled = true

func update_barter():
	$"%Barter".disabled = player.bought

func _on_barter_toggled(pressed):
	emit_signal("bartered")
	bartering = pressed
