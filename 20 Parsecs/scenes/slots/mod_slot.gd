extends TextureRect

signal bartered
signal moved

var player = {
	"bought": false,
	"mod_slot": {
		"visible": true,
		"empty": true,
		"bartering": false,
	}
}

var empty = true
var bartering = false
var _target = null
	
func set_player(player_to_set):
	player = player_to_set

func get_card():
	return $"%ModCard".card

func set_card(card_to_set):
	empty = false
	$"%ModCard".card = card_to_set
	$"%ModCard".show()
	$"%ModCard".update_view()
	$"%Buttons".show()
	update_buttons()

func remove_card():
	empty = true
	$"%ModCard".card = null
	$"%ModCard".hide()
	$"%Buttons".hide()
	
func has_trait(trait):
	if empty:
		return false
	if not $"%ModCard".card.has("trait"):
		return false
	return $"%ModCard".card.trait == trait

func update_target():
	var targets = []
	if player.cargo_mod_slot.empty or player.cargo_mod_slot.get_card().type == "Mod":
		targets.append(player.cargo_mod_slot)
	if has_trait("Smuggling Compartment"):
		if player.cargo_slots[0].empty:
			targets.append(player.cargo_slots[0])
		if player.cargo_slots[1].empty:
			targets.append(player.cargo_slots[1])
	if targets.size() == 0:
		_target = null
		return
	for target in targets:
		if not target.visible:
			continue
		_target = target
		break

func update_buttons():
	if empty:
		return
	update_repair()
	update_barter()
	update_move()

func disable_buttons():
	$"%Barter".disabled = true

func update_repair():
	$"%Repair".hide()

func update_barter():
	$"%Barter".disabled = player.bought

func update_move():
	update_target()
	if _target == null:
		$"%Move".disabled = true
	else:
		$"%Move".disabled = false

func _on_barter_toggled(pressed):
	emit_signal("bartered")
	bartering = pressed

func _on_move_pressed():
	emit_signal("moved", self, _target)
