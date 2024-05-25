tool class_name RichTextVAlign extends RichTextEffect

# Custom Effects: Array[1]: RichTextVAlign
# [img=16]icon.png[/img][valign px=8]Hello World[/valign]

var bbcode := "valign"

func _process_custom_fx(char_fx:CharFXTransform) -> bool:
	char_fx.offset = Vector2.UP * char_fx.env.get("px", 0.0)
	return true
