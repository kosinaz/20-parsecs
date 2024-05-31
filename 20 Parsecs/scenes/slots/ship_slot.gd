extends TextureRect

var damage = 0
var defeated = false
var repaired = false
var player = null
var buy = 0

func get_card():
	return $"%ShipCard".card

func get_armor():
	var armor = $"%ShipCard".card.armor + player.mod_slot.get_armor() + player.cargo_mod_slot.get_armor()
	armor += player.crew_slots[0].get_ship_armor() + player.crew_slots[1].get_ship_armor() + player.crew_slots[2].get_ship_armor()
	return armor

func get_price():
	return $"%ShipCard".card.buy

func set_player(player_to_set):
	player = player_to_set

func set_card(card_to_set):
	$"%ShipCard".card = card_to_set
	$"%ShipCard".update_view()
	$"%ShipDamage".value = 0
	damage = 0
	update_armor()
	buy = card_to_set.buy

func suffer_damage(amount):
	damage += amount
	if damage >= get_armor():
		defeated = true
		damage = get_armor()
	$"%ShipDamage".value = damage
	$"%ShipDamageLabel".text = str(get_armor() - damage) + "/" + str(get_armor())

func repair(amount = 0):
	defeated = false
	if amount == 0:
		amount = damage
	damage -= amount
	$"%ShipDamage".value = damage
	$"%ShipDamageLabel".text = str(get_armor() - damage) + "/" + str(get_armor())
	repaired = true

func update_armor():
	$"%ShipDamage".max_value = get_armor()
	$"%ShipDamageLabel".text = str(get_armor() - damage) + "/" + str(get_armor())
	if damage >= get_armor():
		defeated = true
		damage = get_armor()
