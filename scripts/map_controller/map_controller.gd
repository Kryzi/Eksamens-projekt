extends Node2D

func _ready() -> void:
	
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
	
	$Background/Layout1BridgeShop/TeleporterArea1.body_entered.connect(
	func(body): _on_teleport_area_entered(body, "Teleporter_shop")
	)
	
@onready var map_controller = get_node("/root/Main/MapController")
@onready var background = map_controller.get_node("Background")
@onready var spawner = map_controller.get_node("Spawner")

@onready var layout1 = background.get_node("Layout1")
@onready var layout1_bridge = background.get_node("Layout1Bridge")
@onready var layout1_bridge_shop = background.get_node("Layout1BridgeShop")
@onready var layout2 = background.get_node("Layout2")
@onready var layout2_bridge = background.get_node("Layout2Bridge")
@onready var layoutBoss = background.get_node("LayoutBoss")
#@onready var rewardValue = get_node("/root/Main/MapController/Spawner").teleporter1

func delete_all_things():
	for coin in get_tree().get_nodes_in_group("coin"):
		coin.queue_free()
	for item in get_tree().get_nodes_in_group("item"):
		item.queue_free()
	for projectile in get_tree().get_nodes_in_group("projectile"):
		projectile.queue_free()

#Boss
@export var GigaGed: PackedScene


var stageReward = 0
var rewardValue = 0

func _on_teleport_area_entered(body, teleporter_name):
	if body.is_in_group("player"):
		delete_all_things()
		PlayerInfo.areaID = randi_range(1, 2)
		PlayerInfo.bossTimer += 1
		
		layout1_bridge.visible = false
		layout2_bridge.visible = false
		layout1_bridge_shop.visible = false
		
		# Disable stage collision
		layout1_bridge.get_node("Variation1_1/Boundary1Bridge/CollisionPolygon2D").call_deferred("set_disabled", true) 
		layout1_bridge.get_node("Variation1_2/Boundary1_2Bridge/CollisionPolygon2D").call_deferred("set_disabled", true) 
		layout2_bridge.get_node("Variation2_1/Boundary2Bridge/CollisionPolygon2D").call_deferred("set_disabled", true)
		layout2_bridge.get_node("Variation2_2/BoundaryBridge2_2/CollisionPolygon2D").call_deferred("set_disabled", true)
		layout1_bridge_shop.get_node("Boundary1BridgeShop/CollisionPolygon2D").call_deferred("set_disabled", true)
		layoutBoss.get_node("Boundary/CollisionPolygon2D").call_deferred("set_disabled", true)
		
		
		#Teleporter Collision
		layout1_bridge.get_node("Variation1_1/TeleporterArea1/Teleporter1").call_deferred("set_disabled", true)
		layout1_bridge.get_node("Variation1_2/TeleporterArea1_2/Teleporter1_2").call_deferred("set_disabled", true)
		layout2_bridge.get_node("Variation2_1/TeleporterArea2/Teleporter2").call_deferred("set_disabled", true)
		layout2_bridge.get_node("Variation2_2/TeleporterArea2_2/Teleporter2_2").call_deferred("set_disabled", true)
		layout1_bridge_shop.get_node("TeleporterArea1/Teleporter1").call_deferred("set_disabled", true)
		
		
		#Reward giver
		#print(teleporter_name)
		if (teleporter_name == "Teleporter_1"):
			rewardValue = spawner.teleporter1
			stageReward = rewardValue
			#print("used1")
		elif (teleporter_name == "Teleporter_2"):
			rewardValue = spawner.teleporter2
			stageReward = rewardValue
			#print("used2")
		elif (teleporter_name == "Teleporter_3"):
			rewardValue = spawner.teleporter3
			stageReward = rewardValue
		if (teleporter_name == "Teleporter_shop"):
			#print(rewardValue)
			stageReward = rewardValue
			#print("used3")
		
		layout1_bridge_shop.get_node("Boundary1BridgeShop/CollisionPolygon2D").call_deferred("set_disabled", true)
		var teleporter_collision1_shop = layout1_bridge_shop.get_node("TeleporterArea1/Teleporter1")
		teleporter_collision1_shop.call_deferred("set_disabled", true)
		
		if (PlayerInfo.bossTimer == 10):
			PlayerInfo.areaID = 0
			stageReward = 0
			body.global_position = layoutBoss.get_node("Spawnpoint").position
			
			layoutBoss.visible = true
			layoutBoss.get_node("Boundary/CollisionPolygon2D").call_deferred("set_disabled", false)
			
			var enemy_instance = GigaGed.instantiate()
			enemy_instance.position = layoutBoss.get_node("BossSpawnpoint").position
			call_deferred("add_child", enemy_instance)
			
		
		#Hvis man går ind i en teleporter med stageReward = 3, så fjernes areaID og man garanteret kommer ind i shop
		if (stageReward == 3):
			PlayerInfo.areaID = 0
			stageReward = 0
			body.global_position = layout1_bridge_shop.get_node("Spawnpoint").position
			
			var layout1_bridge_shop_collision = layout1_bridge_shop.get_node("Boundary1BridgeShop/CollisionPolygon2D")
			layout1_bridge_shop_collision.call_deferred("set_disabled", false)
			layout1_bridge_shop.visible = true
			
			rewardValue = randi_range(1, 2) 
			print(rewardValue)
			spawner.rewardSet(rewardValue)
			print(PlayerInfo.mapValue)
			layout1_bridge_shop.get_node("rewardLabel").text = PlayerInfo.mapValue
			
			
			#kaldes her da der ikke er brug for checkDeath() i shop
			teleporter_collision1_shop.call_deferred("set_disabled", false)
			layout1_bridge_shop.RefillShopItems()
		
		if PlayerInfo.areaID == 1:
			body.global_position = layout1.get_node("Spawnpoint").global_position
			
			var layout1_collision = layout1.get_node("Boundary1/CollisionPolygon2D")
			layout1_collision.call_deferred("set_disabled", false)
			layout1.visible = true
			
			var boundary1 = layout1.get_node("EnemyArea1/SpawnPolygon1")
			spawner.create_spawn_area(boundary1)
		
		if PlayerInfo.areaID == 2:
			body.global_position = layout2.get_node("Spawnpoint").global_position
			
			var layout2_collision = layout2.get_node("Boundary2/CollisionPolygon2D")
			layout2_collision.call_deferred("set_disabled", false)
			layout2.visible = true
			
			var boundary2 = layout2.get_node("EnemyArea2/SpawnPolygon2")
			spawner.create_spawn_area(boundary2)
		
		if PlayerInfo.areaID == 3:
			pass
