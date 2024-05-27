extends Node2D
class_name Space

signal pressed
signal contact1
signal contact2

export var space_1 = 0
export var space_2 = 0
export var space_3 = 0
export var space_4 = 0
export var faction = ""
export var planet_name = ""
onready var id = int(name.right(5))
onready var contact1level = int($Contact1.icon.resource_path.substr(19, 1))
onready var contact2level = int($Contact1.icon.resource_path.substr(19, 1))
var contact1 = ""
var contact2 = ""

func enable_contacts():
	$Contact1.disabled = false
	$Contact2.disabled = false

func disable_contacts():
	$Contact1.disabled = true
	$Contact2.disabled = true

func _on_button_pressed():
	emit_signal("pressed", self)

func _on_contact1_pressed():
	emit_signal("pressed", self)

func _on_contact2_pressed():
	emit_signal("pressed", self)
