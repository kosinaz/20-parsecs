extends TextureRect

signal delivered
signal bartered
signal moved

var player = {
	"bought": false,
	"space": {
		"name": "Acan",
	},
	"cargo_slots": [
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
	"cargo_mod_slots": [
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
var _target = null
	
func set_player(player_to_set):
	player = player_to_set

func get_card():
	if $"%CargoCard".visible:
		return $"%CargoCard".card
	return $"%ModCard".card

func set_card(card_to_set):
	empty = false
	if card_to_set.type == "Cargo" or card_to_set.type == "Cargo/Mod":
		$"%CargoCard".card = card_to_set
		$"%CargoCard".show()
		$"%ModCard".hide()
		$"%CargoCard".update_view()
	else:
		$"%ModCard".card = card_to_set
		$"%CargoCard".hide()
		$"%ModCard".show()
		$"%ModCard".update_view()
	$"%Buttons".show()
	update_buttons()

func remove_card():
	empty = true
	$"%CargoCard".card = null
	$"%CargoCard".hide()
	$"%ModCard".card = null
	$"%ModCard".hide()
	$"%Buttons".hide()
	
func has_trait(trait):
	if empty:
		return false
	var card = null
	if $"%CargoCard".visible:
		card = $"%CargoCard".card
	else:
		card = $"%ModCard".card
	if not card.has("trait"):
		return false
	return card.trait == trait

func update_buttons():
	if empty:
		return
	update_deliver()
	update_barter()
	update_move()

func disable_buttons():
	$"%Deliver".disabled = true
	$"%Barter".disabled = true
	$"%Move".disabled = true

func update_target():
	if $"%CargoCard".visible:
		var targets = []
		targets.append_array(player.cargo_slots)
		targets.append(player.cargo_mod_slot)
		if has_trait("Smuggling Compartment"):
			targets.remove(2)
			targets.append(player.mod_slot)
		var i = targets.find(self)
		var ordered_targets = targets.slice(i + 1, targets.size())
		if i > 0:
			ordered_targets.append_array(targets.slice(0, i - 1))
		for target in ordered_targets:
			if not target.visible:
				continue
			if target.has_trait("Smuggling Compartment") and self.name == "CargoSlot3":
				continue
			_target = target
			break
	else:
		var targets = [player.mod_slot, player.cargo_mod_slot]
		if has_trait("Smuggling Compartment"):
			targets.append_array([player.cargo_slots[0], player.cargo_slots[1]])
		var i = targets.find(self)
		var ordered_targets = targets.slice(i + 1, targets.size())
		if i > 0:
			ordered_targets.append_array(targets.slice(0, i - 1))
		for target in ordered_targets:
			if not target.visible:
				continue
			_target = target
			break

func update_deliver():
	if not $"%CargoCard".visible:
		$"%Deliver".hide()
		return
	if $"%CargoCard".card.has("to"):
		$"%Deliver".show()
		$"%Deliver".disabled = player.space_name != $"%CargoCard".card.to
	else:
		$"%Deliver".hide()

func update_barter():
	$"%Barter".disabled = player.bought

func update_move():
	update_target()
	if _target == null:
		$"%Move".disabled = true
	else:
		$"%Move".disabled = false

func _on_deliver_pressed():
	emit_signal("delivered")

func _on_barter_toggled(pressed):
	emit_signal("bartered")
	bartering = pressed

func _on_move_pressed():
	emit_signal("moved", self, _target)
