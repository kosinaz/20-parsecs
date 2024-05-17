extends Node
class_name Gearmods

var deck = [
	{
		"type": "Mod",
		"buy": 2,
		"name": "targeting computer",
		"description": "Reroll blanks in Ship Combat",
		"patrol": "D",
		"move": 3,
	},
	{
		"type": "Mod",
		"buy": 2,
		"name": "quad laser",
		"description": "Attack: +1S",
		"patrol": "C",
		"move": 3,
	},
	{
		"type": "Mod",
		"buy": 3,
		"name": "nav computer",
		"description": "Speed: +1",
	},
	{
		"type": "Mod",
		"buy": 3,
		"name": "shield upgrade",
		"description": "Armor: +1S\nAction: Recover 1 Ship Damage",
	},
	{
		"type": "Mod",
		"buy": 5,
		"name": "maneuvering thrusters",
		"description": "Armor: +1S\nEnemy Attack: -1S if you have Tactics.",
	},
	{
		"type": "Mod",
		"buy": 5,
		"name": "ion cannon",
		"description": "-1 Ship Damage or -2 Ship Damage if you have Tactics.",
		"patrol": "A",
		"move": 3,
	},
]
