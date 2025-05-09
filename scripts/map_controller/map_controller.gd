extends Node2D

func _ready() -> void:
	
	delete_all_things()
	
	$Background/Layout1Bridge/Variation1_1/TeleporterArea1_1.body_entered.connect(
	func(body): _on_teleport_area_entered(body, "Teleporter_1")
	)
	$Background/Layout1Bridge/Variation1_2/TeleporterArea1_2.body_entered.connect(
	func(body): _on_teleport_area_entered(body, "Teleporter_2")
	)
	$Background/Layout1Bridge/Variation1_3/TeleporterArea1_3.body_entered.connect(
	func(body): _on_teleport_area_entered(body, "Teleporter_3")
	)
	
	$Background/Layout2Bridge/Variation2_1/TeleporterArea2_1.body_entered.connect(
	func(body): _on_teleport_area_entered(body, "Teleporter_1")
	)
	$Background/Layout2Bridge/Variation2_2/TeleporterArea2_2.body_entered.connect(
	func(body): _on_teleport_area_entered(body, "Teleporter_2")
	)
	$Background/Layout2Bridge/Variation2_3/TeleporterArea2_3.body_entered.connect(
	func(body): _on_teleport_area_entered(body, "Teleporter_3")
	)
	
	$Background/Layout3Bridge/Variation3_1/TeleporterArea3_1.body_entered.connect(
	func(body): _on_teleport_area_entered(body, "Teleporter_1")
	)
	$Background/Layout3Bridge/Variation3_2/TeleporterArea3_2.body_entered.connect(
	func(body): _on_teleport_area_entered(body, "Teleporter_2")
	)
	$Background/Layout3Bridge/Variation3_3/TeleporterArea3_3.body_entered.connect(
	func(body): _on_teleport_area_entered(body, "Teleporter_3")
	)
	
	$Background/Layout1BridgeShop/TeleporterArea1.body_entered.connect(
	func(body): _on_teleport_area_entered(body, "Teleporter_shop")
	)

@onready var background: Control = $Background
@onready var spawner: Node2D = $Spawner
@onready var musikManager: Node = $MusikManager

@onready var layout1 = background.get_node("Layout1")
@onready var layout1_bridge = background.get_node("Layout1Bridge")
@onready var layout1_bridge_shop = background.get_node("Layout1BridgeShop")
@onready var layout2 = background.get_node("Layout2")
@onready var layout2_bridge = background.get_node("Layout2Bridge")
@onready var layout3 = background.get_node("Layout3")
@onready var layout3_bridge = background.get_node("Layout3Bridge")

@onready var layoutBoss = background.get_node("LayoutBoss")

func delete_all_things():
	for coin in get_tree().get_nodes_in_group("coin"):
		coin.queue_free()
	for item in get_tree().get_nodes_in_group("item"):
		item.queue_free()
	for projectile in get_tree().get_nodes_in_group("projectile"):
		projectile.queue_free()
	for obstacle in get_tree().get_nodes_in_group("obstacle"):
		obstacle.queue_free()

#Boss
@export var GigaGed: PackedScene

func disable_visual_and_collsion():
	# Disable visual of layouts
	layout1_bridge.visible = false
	layout2_bridge.visible = false
	layout3_bridge.visible = false
	layout1_bridge_shop.visible = false
	
	# Disable stage collision
	layout1_bridge.get_node("Variation1_1/BoundaryBridge1_1/CollisionPolygon2D").call_deferred("set_disabled", true) 
	layout1_bridge.get_node("Variation1_2/BoundaryBridge1_2/CollisionPolygon2D").call_deferred("set_disabled", true) 
	layout1_bridge.get_node("Variation1_3/BoundaryBridge1_3/CollisionPolygon2D").call_deferred("set_disabled", true) 
	layout2_bridge.get_node("Variation2_1/BoundaryBridge2_1/CollisionPolygon2D").call_deferred("set_disabled", true)
	layout2_bridge.get_node("Variation2_2/BoundaryBridge2_2/CollisionPolygon2D").call_deferred("set_disabled", true)
	layout2_bridge.get_node("Variation2_3/BoundaryBridge2_3/CollisionPolygon2D").call_deferred("set_disabled", true)
	layout3_bridge.get_node("Variation3_1/BoundaryBridge3_1/CollisionPolygon2D").call_deferred("set_disabled", true)
	layout3_bridge.get_node("Variation3_2/BoundaryBridge3_2/CollisionPolygon2D").call_deferred("set_disabled", true)
	layout3_bridge.get_node("Variation3_3/BoundaryBridge3_3/CollisionPolygon2D").call_deferred("set_disabled", true)
	
	layout1_bridge_shop.get_node("Boundary1BridgeShop/CollisionPolygon2D").call_deferred("set_disabled", true)
	layout1_bridge_shop.get_node("ShopKeeper/StaticBody2D/CollisionShape2D").call_deferred("set_disabled", true)
	layoutBoss.get_node("Boundary/CollisionPolygon2D").call_deferred("set_disabled", true)
	
	#Teleporter Collision
	layout1_bridge.get_node("Variation1_1/TeleporterArea1_1/Teleporter1_1").call_deferred("set_disabled", true)
	layout1_bridge.get_node("Variation1_2/TeleporterArea1_2/Teleporter1_2").call_deferred("set_disabled", true)
	layout1_bridge.get_node("Variation1_3/TeleporterArea1_3/Teleporter1_3").call_deferred("set_disabled", true)
	layout2_bridge.get_node("Variation2_1/TeleporterArea2_1/Teleporter2_1").call_deferred("set_disabled", true)
	layout2_bridge.get_node("Variation2_2/TeleporterArea2_2/Teleporter2_2").call_deferred("set_disabled", true)
	layout2_bridge.get_node("Variation2_3/TeleporterArea2_3/Teleporter2_3").call_deferred("set_disabled", true)
	layout3_bridge.get_node("Variation3_1/TeleporterArea3_1/Teleporter3_1").call_deferred("set_disabled", true)
	layout3_bridge.get_node("Variation3_2/TeleporterArea3_2/Teleporter3_2").call_deferred("set_disabled", true)
	layout3_bridge.get_node("Variation3_3/TeleporterArea3_3/Teleporter3_3").call_deferred("set_disabled", true)
	
	layout1_bridge_shop.get_node("TeleporterArea1/Teleporter1").call_deferred("set_disabled", true)
	
	layout1_bridge_shop.get_node("Boundary1BridgeShop/CollisionPolygon2D").call_deferred("set_disabled", true)
	var teleporter_collision1_shop = layout1_bridge_shop.get_node("TeleporterArea1/Teleporter1")
	teleporter_collision1_shop.call_deferred("set_disabled", true)

func layoutChange(body: Node2D, layoutX: int, layout: Node):
	body.global_position = layout.get_node("Spawnpoint").global_position
	
	var layout_collision = layout.get_node("Boundary%d/CollisionPolygon2D" % [layoutX])
	layout_collision.call_deferred("set_disabled", false)
	layout.visible = true
	musikManager.newStage("kamp")
	
	var boundary = layout.get_node("EnemyArea%d/SpawnPolygon%d" % [layoutX, layoutX])
	spawner.create_spawn_area(boundary)
	var obstacleBoundary = layout.get_node("ObstacleArea%d/CollisionPolygon2D" % [layoutX])
	spawner.call_deferred("generate_obstacles",obstacleBoundary)


var stageReward = 0
var rewardValue = 0

func _on_teleport_area_entered(body, teleporter_name):
	if body.is_in_group("player"):
		delete_all_things()
		disable_visual_and_collsion()
		
		PlayerInfo.areaID = randi_range(1, 3)
		PlayerInfo.bossTimer += 1
		
		if (teleporter_name == "Teleporter_1"):
			rewardValue = spawner.teleporter1
		elif (teleporter_name == "Teleporter_2"):
			rewardValue = spawner.teleporter2
		elif (teleporter_name == "Teleporter_3"):
			rewardValue = spawner.teleporter3
		elif (teleporter_name == "Teleporter_shop"):
			rewardValue = spawner.teleporterShop
		stageReward = rewardValue
		
		
		if (PlayerInfo.bossTimer == 15):
			PlayerInfo.areaID = 0
			stageReward = 0
			body.global_position = layoutBoss.get_node("Spawnpoint").position
			
			layoutBoss.visible = true
			layoutBoss.get_node("Boundary/CollisionPolygon2D").call_deferred("set_disabled", false)
			musikManager.newStage("boss")
			
			var enemy_instance = GigaGed.instantiate()
			enemy_instance.position = layoutBoss.get_node("BossSpawnpoint").position
			call_deferred("add_child", enemy_instance)
			
			get_node("/root/Main/HUD/Control/BossLivbar").visible = true
		
		#Hvis man går ind i en teleporter med stageReward = 3, så fjernes areaID og man garanteret kommer ind i shop
		if (stageReward == 3):
			PlayerInfo.areaID = 0
			body.global_position = layout1_bridge_shop.get_node("Spawnpoint").position
			
			var layout1_bridge_shop_collision = layout1_bridge_shop.get_node("Boundary1BridgeShop/CollisionPolygon2D")
			layout1_bridge_shop_collision.call_deferred("set_disabled", false)
			layout1_bridge_shop.get_node("ShopKeeper/StaticBody2D/CollisionShape2D").call_deferred("set_disabled", false)
			layout1_bridge_shop.visible = true
			musikManager.newStage("shop")
			
			spawner.checkNextShopStage()
			
			layout1_bridge_shop.RefillShopItems()
			
		
		if PlayerInfo.areaID == 1:
			layoutChange(body, 1, layout1)
		if PlayerInfo.areaID == 2:
			layoutChange(body, 2, layout2)
		if PlayerInfo.areaID == 3:
			layoutChange(body, 3, layout3)
		
		
		if (stageReward == 4 or stageReward == 5):
			var amount = randi_range(2, 3)
			if (PlayerInfo.bossTimer >= 6):
				amount = randi_range(3, 4)
			if (PlayerInfo.bossTimer >= 9):
				amount = randi_range(4, 5)
			for i in amount:
				spawner.elite_spawn(i)
