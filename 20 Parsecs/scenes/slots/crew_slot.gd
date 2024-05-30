extends TextureRect

signal dropped

var player = {}
var empty = true
var bartering = false
	
func set_player(player_to_set):
	player = player_to_set

func get_card():
	return $"%CrewCard".card

func set_card(card_to_set):
	empty = false
	$"%CrewCard".card = card_to_set
	$"%CrewCard".show()
	$"%CrewCard".update_view()
	$"%Buttons".show()

func remove_card():
	empty = true
	$"%CrewCard".card = null
	$"%CrewCard".hide()
	$"%Buttons".hide()
	
func has_trait(_trait):
	return false

func update_buttons():
	pass
	
func disable_buttons():
	pass

func _on_drop_pressed():
	emit_signal("dropped", self)
