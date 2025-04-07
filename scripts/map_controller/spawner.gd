extends Node2D

#@export var enemy_1: PackedScene

@export var enemy_1: PackedScene
@export var enemy_2: PackedScene
@export var enemy_3: PackedScene
@export var stone_obstacle: PackedScene
@export var wood_obstacle: PackedScene

@onready var map_controller = get_node("/root/Main/MapController")
@onready var background = map_controller.get_node("Background")

@onready var layout1 = background.get_node("Layout1")
@onready var layout1_bridge = background.get_node("Layout1Bridge")
@onready var layout2 = background.get_node("Layout2")
@onready var layout2_bridge = background.get_node("Layout2Bridge")

@onready var layout1_bridge_shop = background.get_node("Layout1BridgeShop")
@onready var layoutBoss = background.get_node("LayoutBoss")

@onready var boundary = layout1.get_node("EnemyArea1/SpawnPolygon1")
@onready var obstacle_collision_shape = layout1.get_node("ObstacleArea/CollisionShape2D")

@onready var obstacle_scene_array: Array[PackedScene] = [stone_obstacle, wood_obstacle]
var spawnArea: Rect2  # Define a Rect2 for spawn area
var obstacleArea: Rect2
var rewardValue: int = 0
#var mapValue: String = ""

var teleporter1 = 0
var teleporter2 = 0
var teleporter3 = 0
var variationID = 0

func _ready() -> void:
	create_spawn_area(boundary)
	'print(layout1_bridge_shop.visible )
	if (layoutBoss.visible == false and layout1_bridge_shop.visible == false):
		create_obstacle_area(obstacle_collision_shape)'

#func update_navigation_obstacles():
	#var navigation_region = $NavigationRegion2D
	#if navigation_region is NavigationRegion2D:
		#var nav_polygon = navigation_region.navigation_polygon
		#for static_body in get_tree().get_nodes_in_group("obstacle"):
			#if static_body is StaticBody2D:
				#var collision_shape := static_body.get_child("CollisionShape2D") as CollisionShape2D
				#if collision_shape.shape is RectangleShape2D:
					#var rect = collision_shape.size  # Assuming RectangleShape2D
					#var global_position = static_body.global_position
					#nav_polygon.add_collision_polygon(Rect2(global_position - rect / 2, rect))


func create_obstacle_area(new_obstacle_collision_shape: CollisionShape2D) -> void:
	obstacleArea = get_obstacle_area(new_obstacle_collision_shape)
	
	var amount = randi_range(1, 10)
	for i in amount:
		#print(i)
		random_obstacle_generation()
		
func create_spawn_area(new_boundary):
	spawnArea = get_spawn_area(new_boundary)  # Calculate the spawn area bounding box
	
	#print("Spawner ready:", self.name, "from", get_parent())
	var amount = randi_range(1, 4)
	for i in amount:
		#print(i)
		random_spawn()

func get_obstacle_area(collision_shape_for_obstacle_area: CollisionShape2D) -> Rect2:
	var shape = collision_shape_for_obstacle_area.shape
	if shape is RectangleShape2D:
		var size = (shape as RectangleShape2D).size  # Width and height of the rectangle
		var top_left = collision_shape_for_obstacle_area.to_global(-size / 2)
		var bottom_right = collision_shape_for_obstacle_area.to_global(size / 2)
		
		return Rect2(top_left, bottom_right - top_left)  # Create Rect2 from top-left and size
	
	return Rect2()  # Return an empty Rect2 if shape type is unsupported
		
func get_spawn_area(boundary_for_spawn_area: CollisionPolygon2D) -> Rect2:
	var min_x = INF
	var min_y = INF
	var max_x = -INF
	var max_y = -INF
	
	for point in boundary_for_spawn_area.polygon:
		var global_point = boundary_for_spawn_area.to_global(point)  # Convert to global position
		min_x = min(min_x, global_point.x)
		min_y = min(min_y, global_point.y)
		max_x = max(max_x, global_point.x)
		max_y = max(max_y, global_point.y)

	return Rect2(Vector2(min_x, min_y), Vector2(max_x - min_x, max_y - min_y))

func random_obstacle_generation() -> void:
	var rand_x = randf_range(obstacleArea.position.x, obstacleArea.end.x)
	var rand_y = randf_range(obstacleArea.position.y, obstacleArea.end.y)
	var pos = Vector2(rand_x, rand_y)
	var obstacle_scene = obstacle_scene_array.pick_random()
	var obstacle_instance = obstacle_scene.instantiate()
	
	obstacle_instance.position = pos
	call_deferred("add_child", obstacle_instance)

func random_spawn():
	var x = randf_range(spawnArea.position.x, spawnArea.end.x)
	var y = randf_range(spawnArea.position.y, spawnArea.end.y)
	var pos = Vector2(x, y)
	
	# Vælg en tilfældig fjende at spawne
	var enemy_scenes = [enemy_1, enemy_2, enemy_3]
	var selected_enemy = enemy_scenes[randi() % enemy_scenes.size()]
	
	var enemy_instance = selected_enemy.instantiate()
	enemy_instance.position = pos
	call_deferred("add_child", enemy_instance)

func rewardSet(value):
	#rewardValue = randi_range(1, 3)
	rewardValue = value
	if (rewardValue == 1):
		PlayerInfo.mapValue = "Coins"
	if (rewardValue == 2):
		PlayerInfo.mapValue = "Item" 
	if (rewardValue == 3):
		PlayerInfo.mapValue = "Shop"
	if (PlayerInfo.bossTimer == 9):
		PlayerInfo.mapValue = "Boss"

@export var item: PackedScene


func stageReward(Reward):
	if Reward == 1:
		PlayerInfo.current_coins += 20
	if Reward == 2:
		#var boundary = get_node("/root/Main/MapController/Background/Layout1/EnemyArea1/SpawnPolygon1")
		#Find areaID
		match PlayerInfo.areaID:
			1:
				boundary = get_node("/root/Main/MapController/Background/Layout1/EnemyArea1/SpawnPolygon1")
			2:
				boundary = get_node("/root/Main/MapController/Background/Layout2/EnemyArea2/SpawnPolygon2")
		#Skab tilfældigt item
		var itemInstance = item.instantiate()  # Instantiate the PackedScene
		itemInstance.itemGenerator()  # Now you can call itemGenerator() on the instance
		# teleportere tilfældigt item til midten af boundry
		#var polygon = boundary.polygon 
		spawnArea = get_spawn_area(boundary)
		var x = (spawnArea.position.x + spawnArea.end.x)/2
		var y = (spawnArea.position.y + spawnArea.end.y)/2
		var pos = Vector2(x, y)
		itemInstance.position = pos
		call_deferred("add_child", itemInstance)
		
	if Reward == 3:
		pass #Værdien bliver brugt i map_controller
		
	

func checkDeath():
	await get_tree().process_frame
	if get_tree().get_nodes_in_group("enemy").size() == 0:
		# Switch visible background
		var Reward = map_controller.stageReward
		stageReward(Reward)
		
		variationID = randi_range(1, 3)
		
		if layout1.visible == true:
			layout1.visible = false
			layout1.get_node("Boundary1/CollisionPolygon2D").disabled = true
			layout1_bridge.visible = true
			
			layout1_bridge.get_node("Variation1_1/TeleporterArea1/Teleporter1").disabled = false
			layout1_bridge.get_node("Variation1_2").visible = false
			layout1_bridge.get_node("Variation1_3").visible = false
			
			#var rewardLabel = layout1_bridge.get_node("rewardLabel")
			rewardSet(randi_range(1, 3))
			layout1_bridge.get_node("Variation1_1/rewardLabel").text = PlayerInfo.mapValue
			teleporter1 = rewardValue
			
			if (variationID == 1):
				layout1_bridge.get_node("Variation1_1/Boundary1Bridge/CollisionPolygon2D").disabled = false
			
			if (variationID >= 2):
				layout1_bridge.get_node("Variation1_2").visible = true
				
				layout1_bridge.get_node("Variation1_2/Boundary1_2Bridge/CollisionPolygon2D").disabled = false
				layout1_bridge.get_node("Variation1_2/TeleporterArea1_2/Teleporter1_2").disabled = false
				
				rewardSet(randi_range(1, 3))
				layout1_bridge.get_node("Variation1_2/rewardLabel1_2").text = PlayerInfo.mapValue
				teleporter2 = rewardValue
				
				if (variationID == 3):
					layout1_bridge.get_node("Variation1_3").visible = true
					
					layout1_bridge.get_node("Variation1_2/Boundary1_2Bridge/CollisionPolygon2D").disabled = true
					
					layout1_bridge.get_node("Variation1_3/Boundary1_3Bridge/CollisionPolygon2D").disabled = false
					layout1_bridge.get_node("Variation1_3/TeleporterArea1_3/Teleporter1_3").disabled = false
					
					rewardSet(randi_range(1, 3))
					layout1_bridge.get_node("Variation1_3/rewardLabel1_3").text = PlayerInfo.mapValue
					teleporter3 = rewardValue
				
			
			
		
		if layout2.visible == true:
			layout2.visible = false
			layout2.get_node("Boundary2/CollisionPolygon2D").disabled = true
			layout2_bridge.visible = true
			
			#layout1_bridge.get_node("Variation1_2/BoundaryBridge2_3/CollisionPolygon2D").disabled = false
			#layout1_bridge.get_node("Variation1_2/TeleporterArea1_2/Teleporter1_2").disabled = false
			
			layout2_bridge.get_node("Variation2_1/TeleporterArea2/Teleporter2").disabled = false
			
			rewardSet(randi_range(1, 3))
			layout2_bridge.get_node("Variation2_1/rewardLabel2").text = PlayerInfo.mapValue
			teleporter1 = rewardValue
			
			if (variationID == 1):
				layout2_bridge.get_node("Variation2_1/Boundary2Bridge/CollisionPolygon2D").disabled = false
				layout2_bridge.get_node("Variation2_2").visible = false
			
			if (variationID == 2):
				layout2_bridge.get_node("Variation2_2/BoundaryBridge2_2/CollisionPolygon2D").disabled = false
				layout2_bridge.get_node("Variation2_2/TeleporterArea2_2/Teleporter2_2").disabled = false
				rewardSet(randi_range(1, 3))
				layout2_bridge.get_node("Variation2_2/rewardLabel2_2").text = PlayerInfo.mapValue
				teleporter2 = rewardValue
			
