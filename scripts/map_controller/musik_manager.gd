extends Node

@onready var ShopMusik: AudioStreamPlayer = $ShopOgUdenFare

func playMusik(musik: AudioStreamPlayer):
	endMusik()
	musik.play()

func endMusik():
	var sange = get_children()
	for item in sange:
		item.stop()

func newStage(stageName):
	print("playing musik - stageReward: " + stageName)
	if stageName == "shop":
		playMusik(ShopMusik)
	elif stageName == "boss":
		endMusik()
	elif stageName == "kamp":
		endMusik()
	else:
		endMusik()
