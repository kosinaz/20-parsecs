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
	$"%To".text = to
	$"%Buy".text = str(buy)
	$"%Sell".text = str(sell)
	$"%Rep".text = rep
	$"%Patrol".text = patrol
	$"%Move".text = str(move)
