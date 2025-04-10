extends Node

@onready var ShopMusik: AudioStreamPlayer = $ShopOgUdenFare
@onready var KampMusik: AudioStreamPlayer = $IKamp

func playMusik(musik: AudioStreamPlayer):
	if musik.playing == false:
		endMusik()
		musik.play()
		#musik.looping = true

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
		playMusik(KampMusik)
	else:
		endMusik()
