extends Node2D

var fame = 0
var money = 0
var ahut = 0
var basyn = 0
var cimp = 0
var dreb = 0

var bought = true
var skipped = true
var discount = 0
onready var space = $"%Space3"
var space_name = "Acan"
onready var gear_slots = [$"%GearSlot", $"%GearSlot2"]
onready var bounty_job_slots = [$"%BountyJobSlot", $"%BountyJobSlot2"]
onready var cargo_slots = [$"%CargoSlot", $"%CargoSlot2", $"%CargoSlot3"]
onready var cargo_mod_slot = $"%CargoModSlot"
onready var mod_slot = $"%ModSlot"
onready var ship_slots = [$"%CargoSlot", $"%CargoSlot2", $"%CargoSlot3", $"%CargoModSlot", $"%ModSlot"]
onready var slots = [$"%GearSlot", $"%GearSlot2", $"%BountyJobSlot", $"%BountyJobSlot2", $"%CargoSlot", $"%CargoSlot2", $"%CargoSlot3", $"%CargoModSlot", $"%ModSlot"]
	
func get_money():
	return money

func get_price(slot):
	if slot.empty:
		return 0
	return slot.get_card().buy

func get_reputation(rep):
	if rep == "A":
		return ahut
	if rep == "B":
		return basyn
	if rep == "C":
		return cimp
	if rep == "D":
		return dreb

func update_discount():
	discount = 0
	for slot in slots:
		if slot.bartering:
			discount += get_price(slot)

func increase_money(amount):
	money += amount
	$"%Money".text = "Money: " + str(money) + "K"
	
func decrease_money(amount):
	money -= amount
	money = max(money, 0)
	$"%Money".text = "Money: " + str(money) + "K"
	
func increase_fame(amount):
	fame += amount
	$"%Fame".text = "Fame: " + str(fame) + "F"
	
func decrease_fame(amount):
	fame -= amount
	fame = max(fame, 0)
	$"%Fame".text = "Fame: " + str(fame) + "F"

func increase_reputation(reputation):
	if reputation == "A" and ahut < 1:
		ahut += 1
	if reputation == "B" and basyn < 1:
		basyn += 1
	if reputation == "C" and cimp < 1:
		cimp += 1
	if reputation == "D" and dreb < 1:
		dreb += 1
	$"%Reputations".text = "Reputations:\nAhut: " + str(ahut) + "AR\nBasyn: " + str(basyn) + "BR\nCimp: " + str(cimp) + "CR\nDreb: " + str(dreb) + "DR"

func decrease_reputation(reputation):
	if reputation == "A" and ahut > -1:
		ahut -= 1
	if reputation == "B" and basyn > -1:
		basyn -= 1
	if reputation == "C" and cimp > -1:
		cimp -= 1
	if reputation == "D" and dreb > -1:
		dreb -= 1
	$"%Reputations".text = "Reputations:\nAhut: " + str(ahut) + "AR\nBasyn: " + str(basyn) + "BR\nCimp: " + str(cimp) + "CR\nDreb: " + str(dreb) + "DR"

