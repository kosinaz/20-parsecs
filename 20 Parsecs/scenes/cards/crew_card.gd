extends VBoxContainer

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
