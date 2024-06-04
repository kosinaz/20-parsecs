extends VBoxContainer

signal helped

var card = {
	"name": "San",
	"attack": 3,
	"armor": 4,
	"skills": ["piloting", "tactics"]
}

func _ready():
	update_view()

func update_view():
	$"%Attack".text = str(card.attack)
	$"%Armor".text = str(card.armor)
	for skill in $"%Skills".get_children():
		if card.skills.has(skill.name.to_lower()):
			skill.show()
		else:
			skill.hide()

func _on_help_pressed():
	emit_signal("helped", "Character\nSan\n3 ground attack\n4 ground armor\nSkills: piloting, tactics")
