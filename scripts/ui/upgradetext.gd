extends RichTextLabel

func ShowText(Upgrades):
	visible = true
	text = "Du har fået " + Upgrades
	
	await get_tree().create_timer(2.5).timeout
	
	visible = false
	
