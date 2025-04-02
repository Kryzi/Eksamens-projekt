extends HBoxContainer

#@onready var slots: Array[Node] = get_node(".").get_children()
var slots: Array[Node] = []
var weapons: Array[Node] = []
@onready var weaponNode = get_node("/root/Main/Player/Weapon")
@onready var icons = get_node("WeaponIcons").get_children()
var i = 0
var standartColor: Color = Color.DIM_GRAY
var highlightColor: Color = Color.WHITE
var ammoOutColor: Color = Color.DARK_RED
var ammoOutHighlight: Color = Color.RED

func _ready() -> void:
	checkForNewWeapons()
	HighlightWeapon()

func _process(_delta: float) -> void:
	pass
	#if ((i) > 100):
	#	checkForNewWeapons()
	#	HighlightWeapon()
	#	i = 0
	#else:
	#	i += 1

func getWeapons():
	weapons.clear()
	weapons = weaponNode.get_children()

func getSlots():
	slots.clear()
	slots = get_children()

func chech_slot_n(slot: Node, n: int):
	var slotWeapon = weapons[n]
	var WeaponName = slotWeapon.get_meta("IconId")
	for icon in icons:
		if (WeaponName + "Icon" == icon.name):
			if (slot.get_child_count() < 1):
				slots[n].add_child(icon.duplicate())
			else:
				deleteTextures(slot)
				slots[n].add_child(icon.duplicate())

func checkForNewWeapons():
	getSlots()
	getWeapons()
	for i in range(slots.size()):
		slots[i].modulate = standartColor
		slots[i].self_modulate = standartColor
		if (i < weapons.size()):
			chech_slot_n(slots[i], i)
			CheckAmmoN(slots[i], weapons[i], i)
		else:
			deleteTextures(slots[i])
		

func HighlightWeapon():
	var currentWeapon = weaponNode.currentWeapon
	print("currentWeapon: " + str(currentWeapon))
	if (slots[currentWeapon].self_modulate == ammoOutColor):
		slots[currentWeapon].modulate = ammoOutHighlight
		slots[currentWeapon].self_modulate = ammoOutHighlight
	else:
		slots[currentWeapon].modulate = highlightColor
		slots[currentWeapon].self_modulate = highlightColor

func CheckAmmoN(slot, weapon, _n): # N bliver ikke brugt ?
	if (weapon.currentAmmo <= 0 and weapon.reserveAmmo <= 0):
		slot.modulate = ammoOutColor
		slot.self_modulate = ammoOutColor

func deleteTextures(slot: Node):
	var textures = slot.get_children()
	var textureNum = slot.get_child_count()
	if (textureNum > 0 and slot.name != "WeaponIcons"):
		for i in textures:
			i.queue_free()
