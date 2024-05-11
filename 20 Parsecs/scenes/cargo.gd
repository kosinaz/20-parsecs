extends MarginContainer

var to = ""
var buy = 0
var sell = 0
var rep = ""
var patrol = ""
var move = 0

func setup(data):
	to = data.to
	buy = data.buy
	sell = data.sell
	rep = data.rep
	patrol = data.patrol
	move = data.move
	$"%Label".text = "To: " + to + "\n"
	$"%Label".text += "Buy: " + str(buy) + "\n"
	$"%Label".text += "Sell: " + str(sell) + "\n"
	$"%Label".text += "Rep: " + rep + "\n"
	$"%Label".text += "Patrol: " + patrol + "\n"
	$"%Label".text += "Move: " + str(move)
