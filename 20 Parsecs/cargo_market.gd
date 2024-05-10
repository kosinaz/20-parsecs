extends MarginContainer

var cargos = []

# Called when the node enters the scene tree for the first time.
func _ready():
	cargos = $Cargos.get_children()
	for cargo in cargos:
		cargo.hide()
		cargo.get_node("Cargo").get_node("%BuyButton").connect("pressed", self, "_on_buy_pressed", [cargo])
		cargo.get_node("Cargo").get_node("%DiscardButton").connect("pressed", self, "_on_discard_pressed", [cargo])
	randomize()
	cargos.shuffle()
	cargos[0].show()

func _on_buy_pressed(cargo):
	cargo.hide()
	cargos.remove(0)
	cargos[0].show()

func _on_discard_pressed(cargo):
	cargo.hide()
	cargos.append(cargos[0])
	cargos.remove(0)
	cargos[0].show()
	print(cargos)
