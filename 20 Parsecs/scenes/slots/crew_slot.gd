extends TextureRect

signal dropped

var player = {}
var empty = true
var bartering = false
	
func set_player(player_to_set):
	player = player_to_set

func get_card():
	return $"%CrewCard".card

func has_mol():
	if empty:
		return false
	return $"%CrewCard".card.name == "Mol"

func has_crew(crew_name):
	if empty:
		return false
	return $"%CrewCard".card.name == crew_name

func get_ground_armor():
	if empty:
		return 0
	if not $"%CrewCard".card.has("ground_armor"):
		return 0
	return $"%CrewCard".card.ground_armor
	
func get_ship_armor():
	if empty:
		return 0
	if not $"%CrewCard".card.has("ship_armor"):
		return 0
	return $"%CrewCard".card.ship_armor

func set_card(card_to_set):
	empty = false
	$"%CrewCard".card = card_to_set
	$"%CrewCard".show()
	$"%CrewCard".update_view()
	$"%Buttons".show()
	player.update_fame_text()

func remove_card():
	empty = true
	$"%CrewCard".card = null
	$"%CrewCard".hide()
	$"%Buttons".hide()
	player.update_fame_text()
	
func has_trait(_trait):
	return false

func update_buttons():
	pass
	
func disable_buttons():
	pass

func _on_drop_pressed():
	emit_signal("dropped", self)
