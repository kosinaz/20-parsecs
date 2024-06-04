extends VBoxContainer

signal helped

var card = {
	"name": "Mol",
	"skills": ["tactics"],
	"ground_attack": 1,
}

func _ready():
	update_view()

func update_view():
	$"%Name".text = card.name
	$"%Mol".visible = card.name == "Mol"
	$"%Acc".visible = card.name == "Acc"
	$"%Dio".visible = card.name == "Dio"
	for skill in $"%Skills".get_children():
		if card.skills.has(skill.name.to_lower()):
			skill.show()
		else:
			skill.hide()

func _on_help_pressed():
	var text = "Crew\n" + card.name + "\n"
	text += "Skills: " + card.skills[0]
	if card.skills.size() > 1:
		for i in card.skills.size() - 1:
			text += ", " + card.skills[i + 1]
	if card.has("help"):
		text += "\n" + card.help
	emit_signal("helped", text)
