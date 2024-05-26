extends TextureRect

var damage = 0
var defeated = false
var player = null

func get_card():
	return $"%CharacterCard".card

func get_armor():
	return $"%CharacterCard".card.armor + player.gear_slots[0].get_armor() + player.gear_slots[1].get_armor()
	
func get_price():
	return $"%ShipCard".card.buy

func set_player(player_to_set):
	player = player_to_set

func set_card(card_to_set):
	$"%CharacterCard".card = card_to_set
	$"%CharacterCard".update_view()
	$"%CharacterDamage".value = 0
	update_armor()

func suffer_damage(amount):
	damage += amount
	if damage >= get_armor():
		defeated = true
		damage = get_armor()
	$"%CharacterDamage".value = damage
	$"%CharacterDamageLabel".text = str(get_armor() - damage) + "/" + str(get_armor())

func heal(amount = 0):
	defeated = false
	if amount == 0:
		amount = damage
	damage -= amount
	$"%CharacterDamage".value = damage
	$"%CharacterDamageLabel".text = str(get_armor() - damage) + "/" + str(get_armor())

func update_armor():
	$"%CharacterDamage".max_value = get_armor()
	$"%CharacterDamageLabel".text = str(get_armor() - damage) + "/" + str(get_armor())
	if damage >= get_armor():
		defeated = true
		damage = get_armor()
