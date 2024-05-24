extends TextureRect

signal bartered
signal moved
signal repaired

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
	if not $"%ModCard".card.has("trait"):
		return false
	return $"%ModCard".card.trait == trait

func update_target():
	_target = null
	if $"%CargoCard".visible:
		var targets = []
		targets.append(player.cargo_slots[0])
		targets.append(player.cargo_slots[1])
		targets.append(player.cargo_mod_slot)
		for target in targets:
			if not target.visible:
				continue
			_target = target
			break
	else:
		if player.cargo_mod_slot.visible and (player.cargo_mod_slot.empty or player.cargo_mod_slot.get_card().type == "Mod"):
			_target = player.cargo_mod_slot

func update_buttons():
	if empty:
		return
	update_repair()
	update_barter()
	update_move()

func disable_buttons():
	$"%Repair".disabled = true
	$"%Barter".disabled = true
	$"%Move".disabled = true

func update_repair():
	$"%Repair".visible = $"%ModCard".visible and $"%ModCard".card.name == "shield upgrade"
	$"%Repair".disabled = player.repaired

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

func _on_repair_pressed():
	$"%Repair".disabled = true
	emit_signal("repaired")
