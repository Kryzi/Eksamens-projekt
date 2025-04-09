extends RichTextLabel

func ShowText(Upgrades):
	visible = true
	text = "Du har fået " + Upgrades + " til alle dine våben"
	
	await get_tree().create_timer(2.5).timeout
	
	visible = false
	
