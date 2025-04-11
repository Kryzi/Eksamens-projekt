extends Node2D

func _ready() -> void:
	
	delete_all_things()
	
	$Background/Layout1Bridge/Variation1_1/TeleporterArea1.body_entered.connect(
	func(body): _on_teleport_area_entered(body, "Teleporter_1")
	)
	$Background/Layout1Bridge/Variation1_2/TeleporterArea1_2.body_entered.connect(
	func(body): _on_teleport_area_entered(body, "Teleporter_2")
	)
	$Background/Layout1Bridge/Variation1_3/TeleporterArea1_3.body_entered.connect(
	func(body): _on_teleport_area_entered(body, "Teleporter_3")
	)
	
	$Background/Layout2Bridge/Variation2_1/TeleporterArea2.body_entered.connect(
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
	
@onready var map_controller = get_node("/root/Main/MapController")
@onready var background = map_controller.get_node("Background")
@onready var spawner = map_controller.get_node("Spawner")
@onready var musikManager = map_controller.get_node("MusikManager")

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


var stageReward = 0
var rewardValue = 0

func _on_teleport_area_entered(body, teleporter_name):
	if body.is_in_group("player"):
		delete_all_things()
		PlayerInfo.areaID = randi_range(1, 3)
		PlayerInfo.bossTimer += 1
		
		layout1_bridge.visible = false
		layout2_bridge.visible = false
		layout3_bridge.visible = false
		layout1_bridge_shop.visible = false
		
		# Disable stage collision
		layout1_bridge.get_node("Variation1_1/Boundary1Bridge/CollisionPolygon2D").call_deferred("set_disabled", true) 
		layout1_bridge.get_node("Variation1_2/Boundary1_2Bridge/CollisionPolygon2D").call_deferred("set_disabled", true) 
		layout1_bridge.get_node("Variation1_3/Boundary1_3Bridge/CollisionPolygon2D").call_deferred("set_disabled", true) 
		layout2_bridge.get_node("Variation2_1/Boundary2Bridge/CollisionPolygon2D").call_deferred("set_disabled", true)
		layout2_bridge.get_node("Variation2_2/BoundaryBridge2_2/CollisionPolygon2D").call_deferred("set_disabled", true)
		layout2_bridge.get_node("Variation2_3/BoundaryBridge2_3/CollisionPolygon2D").call_deferred("set_disabled", true)
		layout3_bridge.get_node("Variation3_1/Boundary3_1/CollisionPolygon2D").call_deferred("set_disabled", true)
		layout3_bridge.get_node("Variation3_2/Boundary3_2/CollisionPolygon2D").call_deferred("set_disabled", true)
		layout3_bridge.get_node("Variation3_3/Boundary3_3/CollisionPolygon2D").call_deferred("set_disabled", true)
		
		layout1_bridge_shop.get_node("Boundary1BridgeShop/CollisionPolygon2D").call_deferred("set_disabled", true)
		layout1_bridge_shop.get_node("ShopKeeper/StaticBody2D/CollisionShape2D").call_deferred("set_disabled", true)
		layoutBoss.get_node("Boundary/CollisionPolygon2D").call_deferred("set_disabled", true)
		
		
		#Teleporter Collision
		layout1_bridge.get_node("Variation1_1/TeleporterArea1/Teleporter1").call_deferred("set_disabled", true)
		layout1_bridge.get_node("Variation1_2/TeleporterArea1_2/Teleporter1_2").call_deferred("set_disabled", true)
		layout1_bridge.get_node("Variation1_3/TeleporterArea1_3/Teleporter1_3").call_deferred("set_disabled", true)
		layout2_bridge.get_node("Variation2_1/TeleporterArea2/Teleporter2").call_deferred("set_disabled", true)
		layout2_bridge.get_node("Variation2_2/TeleporterArea2_2/Teleporter2_2").call_deferred("set_disabled", true)
		layout2_bridge.get_node("Variation2_3/TeleporterArea2_3/Teleporter2_3").call_deferred("set_disabled", true)
		layout3_bridge.get_node("Variation3_1/TeleporterArea3_1/Teleporter3_1").call_deferred("set_disabled", true)
		layout3_bridge.get_node("Variation3_2/TeleporterArea3_2/Teleporter3_2").call_deferred("set_disabled", true)
		layout3_bridge.get_node("Variation3_3/TeleporterArea3_3/Teleporter3_3").call_deferred("set_disabled", true)
		
		layout1_bridge_shop.get_node("TeleporterArea1/Teleporter1").call_deferred("set_disabled", true)
		
		
		if (teleporter_name == "Teleporter_1"):
			rewardValue = spawner.teleporter1
			stageReward = rewardValue
		elif (teleporter_name == "Teleporter_2"):
			rewardValue = spawner.teleporter2
			stageReward = rewardValue
		elif (teleporter_name == "Teleporter_3"):
			rewardValue = spawner.teleporter3
			stageReward = rewardValue
		if (teleporter_name == "Teleporter_shop"):
			stageReward = rewardValue
		
		layout1_bridge_shop.get_node("Boundary1BridgeShop/CollisionPolygon2D").call_deferred("set_disabled", true)
		var teleporter_collision1_shop = layout1_bridge_shop.get_node("TeleporterArea1/Teleporter1")
		teleporter_collision1_shop.call_deferred("set_disabled", true)
		
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
			stageReward = 0
			body.global_position = layout1_bridge_shop.get_node("Spawnpoint").position
			
			var layout1_bridge_shop_collision = layout1_bridge_shop.get_node("Boundary1BridgeShop/CollisionPolygon2D")
			layout1_bridge_shop_collision.call_deferred("set_disabled", false)
			layout1_bridge_shop.get_node("ShopKeeper/StaticBody2D/CollisionShape2D").call_deferred("set_disabled", false)
			layout1_bridge_shop.visible = true
			musikManager.newStage("shop")
			
			rewardValue = randi_range(1, 3)
			if (PlayerInfo.bossTimer >= 4 and randi_range(1, 2) == 3 ):
				rewardValue += 3
			if (PlayerInfo.bossTimer >= 9 and randi_range(2, 3) == 3 ):
				rewardValue += 3
			spawner.rewardSet(rewardValue)
			layout1_bridge_shop.get_node("rewardLabel").text = PlayerInfo.mapValue
			layout1_bridge_shop.get_node("rewardIcon").play(PlayerInfo.mapValue)
			
			#kaldes her da der ikke er brug for checkDeath() i shop
			teleporter_collision1_shop.call_deferred("set_disabled", false)
			layout1_bridge_shop.RefillShopItems()
		
		if PlayerInfo.areaID == 1:
			body.global_position = layout1.get_node("Spawnpoint").global_position
			
			var layout1_collision = layout1.get_node("Boundary1/CollisionPolygon2D")
			layout1_collision.call_deferred("set_disabled", false)
			layout1.visible = true
			musikManager.newStage("kamp")
			
			var boundary1 = layout1.get_node("EnemyArea1/SpawnPolygon1")
			spawner.create_spawn_area(boundary1)
			var obstacleBoundary1 = layout1.get_node("ObstacleArea1/CollisionPolygon2D")
			spawner.call_deferred("generate_obstacles",obstacleBoundary1)
		
		if PlayerInfo.areaID == 2:
			body.global_position = layout2.get_node("Spawnpoint").global_position
			
			var layout2_collision = layout2.get_node("Boundary2/CollisionPolygon2D")
			layout2_collision.call_deferred("set_disabled", false)
			layout2.visible = true
			musikManager.newStage("kamp")
			
			var boundary2 = layout2.get_node("EnemyArea2/SpawnPolygon2")
			spawner.create_spawn_area(boundary2)
			var obstacleBoundary2 = layout2.get_node("ObstacleArea2/CollisionPolygon2D")
			spawner.call_deferred("generate_obstacles",obstacleBoundary2)
		
		if PlayerInfo.areaID == 3:
			body.global_position = layout3.get_node("Spawnpoint").global_position
			
			var layout3_collision = layout3.get_node("Boundary3/CollisionPolygon2D")
			layout3_collision.call_deferred("set_disabled", false)
			layout3.visible = true
			musikManager.newStage("kamp")
			
			var boundary3 = layout3.get_node("EnemyArea3/SpawnPolygon3")
			spawner.create_spawn_area(boundary3)
			var obstacleBoundary3 = layout3.get_node("ObstacleArea3/CollisionPolygon2D")
			spawner.call_deferred("generate_obstacles",obstacleBoundary3)
		
		if (stageReward == 4 or stageReward == 5):
			var amount = randi_range(2, 3)
			if (PlayerInfo.bossTimer >= 6):
				amount = randi_range(3, 4)
			if (PlayerInfo.bossTimer >= 9):
				amount = randi_range(4, 5)
			for i in amount:
				spawner.elite_spawn(i)
