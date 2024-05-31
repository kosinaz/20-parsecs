extends Node

var deck = [
	["Tne", "Naz", "Nad", "Tob", "Aba", "El1"],
	["Mol", "Anu", "Keh", "Ode", "Aka", "Dio", "Ana"],
	["Nat", "Acc", "Rag", "Nwa", "All", "Os2", "Ata", "Are", "Jom"],
]

func _ready():
	deck[0].shuffle()
	deck[1].shuffle()
	deck[2].shuffle()
