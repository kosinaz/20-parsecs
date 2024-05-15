extends Node2D
class_name Space

signal pressed

export var space_1 = 0
export var space_2 = 0
export var space_3 = 0
export var space_4 = 0
onready var id = int(name.right(5))
onready var faction = $Faction.text.trim_prefix("(").left(1)

func _on_button_pressed():
	emit_signal("pressed", self)
