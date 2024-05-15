extends Node2D

var current_space = 0
var fame = 0
var money = 0
var ahut = 0
var bsyn = 0
var cimp = 0
var dreb = 0
	
func get_money():
	return money
	
func increase_money(amount):
	money += amount
	$"%Money".text = "Money: " + str(money) + "K"
	
func decrease_money(amount):
	money -= amount
	$"%Money".text = "Money: " + str(money) + "K"
	
func increase_fame(amount):
	fame += amount
	$"%Fame".text = "Fame: " + str(fame) + "F"
	
func decrease_fame(amount):
	fame -= amount
	$"%Fame".text = "Fame: " + str(fame) + "F"

func increase_reputation(reputation):
	if reputation == "A" and ahut < 1:
		ahut += 1
	if reputation == "B" and bsyn < 1:
		bsyn += 1
	if reputation == "C" and cimp < 1:
		cimp += 1
	if reputation == "D" and dreb < 1:
		dreb += 1
	$"%Reputation".text = "Reputations:\nAhut: " + str(ahut) + "AR\nBasyn: " + str(bsyn) + "BR\nCimp: " + str(cimp) + "CR\nDreb: " + str(dreb) + "DR"

func decrease_reputation(reputation):
	if reputation == "A" and ahut > -1:
		ahut -= 1
	if reputation == "B" and bsyn > -1:
		bsyn -= 1
	if reputation == "C" and cimp > -1:
		cimp -= 1
	if reputation == "D" and dreb > -1:
		dreb -= 1
	$"%Reputation".text = "Reputations:\nAhut: " + str(ahut) + "AR\nBasyn: " + str(bsyn) + "BR\nCimp: " + str(cimp) + "CR\nDreb: " + str(dreb) + "DR"
