extends Node2D
class_name Space

signal pressed
signal contacted

export var space_1 = 0
export var space_2 = 0
export var space_3 = 0
export var space_4 = 0
export var faction = ""
export var planet_name = ""
onready var id = int(name.right(5))
onready var contacts = [
	{
		"name": "",
		"level": int($Contact1.icon.resource_path.substr(19, 1)),
	},
	{
		"name": "",
		"level": int($Contact2.icon.resource_path.substr(19, 1)),
	},
]

func add_contact(button_id, name):
	contacts[button_id].name = name
	get_node("Contact" + str(button_id + 1)).text = name
	
func remove_contact(contact_name):
	if contacts[0].name == contact_name:
		$Contact1.hide()
	if contacts[1].name == contact_name:
		$Contact2.hide()

func enable_contacts():
	$Contact1.disabled = false
	$Contact2.disabled = false

func disable_contacts():
	$Contact1.disabled = true
	$Contact2.disabled = true

func _on_button_pressed():
	emit_signal("pressed", self)

func _on_contact1_pressed():
	emit_signal("contacted", self, 0)

func _on_contact2_pressed():
	emit_signal("contacted", self, 1)
