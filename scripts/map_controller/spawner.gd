extends Node2D

#@export var enemy_1: PackedScene

@export var enemy_1: PackedScene
@export var enemy_2: PackedScene
@export var enemy_3: PackedScene
@export var stone_obstacle: PackedScene
@export var wood_obstacle: PackedScene

@onready var obstacle_scenes: Array[PackedScene] = [stone_obstacle, wood_obstacle]

@onready var main = get_node("/root/Main/")
@onready var map_controller = main.get_node("MapController")
@onready var navigation_region: NavigationRegion2D = main.get_node("NavigationRegion2D")
@onready var background = map_controller.get_node("Background")

@onready var layout1 = background.get_node("Layout1")
@onready var layout1_bridge = background.get_node("Layout1Bridge")
@onready var layout2 = background.get_node("Layout2")
@onready var layout2_bridge = background.get_node("Layout2Bridge")
@onready var layout3 = background.get_node("Layout3")
@onready var layout3_bridge = background.get_node("Layout3Bridge")

@onready var layout1_bridge_shop = background.get_node("Layout1BridgeShop")
@onready var layoutBoss = background.get_node("LayoutBoss")

@onready var boundary: CollisionPolygon2D = layout1.get_node("EnemyArea1/SpawnPolygon1")
@onready var obstacle_boundary: CollisionPolygon2D = layout1.get_node("ObstacleArea1/CollisionPolygon2D")

var min_obstacle_spacing: int = 300
var generated_obstacle_positions: Array[Vector2]
var max_single_obstacle_generation_attempts: int = 5
var obstacleArea: Rect2
var obstacleAreaPolygon: PackedVector2Array

var spawnArea: Rect2  # Define a Rect2 for spawn area
var rewardValue: int = 0
#var mapValue: String = ""

var teleporter1 = 0
var teleporter2 = 0
var teleporter3 = 0
var variationID = 0

func _ready() -> void:
	create_spawn_area(boundary)
	generate_obstacles(obstacle_boundary)
	#print(layout1_bridge_shop.visible )
	#if (layoutBoss.visible == false and layout1_bridge_shop.visible == false):
		#create_obstacle_area(obstacle_collision_shape)

#region Obstacle generation
func generate_obstacles(new_obstacle_boundary: CollisionPolygon2D) -> void:
	obstacleAreaPolygon = get_obstacle_area_polygon(new_obstacle_boundary)
	obstacleArea = get_area_from_boundary(new_obstacle_boundary)
	
	var amount = randi_range(10, 50)
	# Reset previously generated obstacle positions
	generated_obstacle_positions = []
	for i in amount:
		random_obstacle_generation()
		
	call_deferred("awaited_navigation_region_baking")

func awaited_navigation_region_baking() -> void:
	await get_tree().physics_frame
	navigation_region.bake_navigation_polygon()

func get_obstacle_area_polygon(collision_polygon: CollisionPolygon2D) -> PackedVector2Array:
	# Converts the local polygon points to global positions and stores them in a PackedVector2Array
	var global_polygon_points = PackedVector2Array()
	for local_point in collision_polygon.polygon:
		global_polygon_points.append(collision_polygon.to_global(local_point))
	return global_polygon_points

func random_obstacle_generation() -> void:
	for attempt in range(max_single_obstacle_generation_attempts):
		var rand_x = randf_range(obstacleArea.position.x, obstacleArea.end.x)
		var rand_y = randf_range(obstacleArea.position.y, obstacleArea.end.y)
		var pos = Vector2(rand_x, rand_y)
		if Geometry2D.is_point_in_polygon(pos, obstacleAreaPolygon) and is_obstacle_position_valid(pos):
			var obstacle_scene = obstacle_scenes.pick_random()
			var obstacle_instance = obstacle_scene.instantiate()
			obstacle_instance.position = pos
			generated_obstacle_positions.append(pos)
			call_deferred("add_child", obstacle_instance)
			break

func is_obstacle_position_valid(new_pos: Vector2) -> bool:
	for obstacle_position in generated_obstacle_positions:
		if obstacle_position.distance_to(new_pos) < min_obstacle_spacing:
			return false
	return true
#endregion Obstacle generation

#region Enemy spawning
func create_spawn_area(new_boundary):
	spawnArea = get_area_from_boundary(new_boundary)  # Calculate the spawn area bounding box
	
	#print("Spawner ready:", self.name, "from", get_parent())
	var amount = randi_range(1, 4)
	for i in amount:
		#print(i)
		random_spawn()
		
func get_area_from_boundary(boundary_for_spawn_area: CollisionPolygon2D) -> Rect2:
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
#endregion Enemy Spawning

func rewardSet(value):
	#rewardValue = randi_range(1, 3)
	var eliteChance = 0
	if (PlayerInfo.bossTimer == 5):
		eliteChance = randi_range(1, 3)
	
	rewardValue = value
	if (rewardValue == 1):
		PlayerInfo.mapValue = "Coins"
	if (rewardValue == 2):
		PlayerInfo.mapValue = "Item" 
	if (eliteChance == 3 and (rewardValue == 1 or rewardValue == 2)):
		PlayerInfo.mapValue = ("Elite " + PlayerInfo.mapValue)
		rewardValue += 3
	if (rewardValue == 3):
		PlayerInfo.mapValue = "Shop"
	if (PlayerInfo.bossTimer == 14):
		PlayerInfo.mapValue = "Boss"

@export var item: PackedScene


func stageReward(Reward):
	if Reward == 1:
		PlayerInfo.current_coins += 20
	if Reward == 2:
		getItem()
	if Reward == 3:
		pass #Værdien bliver brugt i map_controller
	if Reward == 4:
		PlayerInfo.current_coins += 40
	if Reward == 5:
		getItem()
		getItem()

func getItem():
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
	spawnArea = get_area_from_boundary(boundary)
	var x = (spawnArea.position.x + spawnArea.end.x)/randf_range(2,2.75)
	#var y = (spawnArea.position.y + spawnArea.end.y)/2
	var y = (spawnArea.position.y + spawnArea.end.y)/randf_range(2,2.75)
	var pos = Vector2(x, y)
	itemInstance.position = pos
	call_deferred("add_child", itemInstance)

	

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
			rewardSet(randi_range(1, 2))
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
			
			layout2_bridge.get_node("Variation2_1/TeleporterArea2/Teleporter2").disabled = false
			layout2_bridge.get_node("Variation2_2").visible = false
			layout2_bridge.get_node("Variation2_3").visible = false
			
			
			rewardSet(randi_range(1, 3))
			layout2_bridge.get_node("Variation2_1/rewardLabel2").text = PlayerInfo.mapValue
			teleporter1 = rewardValue
			
			if (variationID == 1):
				layout2_bridge.get_node("Variation2_1/Boundary2Bridge/CollisionPolygon2D").disabled = false
				layout2_bridge.get_node("Variation2_2").visible = false
			
			if (variationID >= 2):
				layout2_bridge.get_node("Variation2_2").visible = true
				
				layout2_bridge.get_node("Variation2_2/BoundaryBridge2_2/CollisionPolygon2D").disabled = false
				layout2_bridge.get_node("Variation2_2/TeleporterArea2_2/Teleporter2_2").disabled = false
				rewardSet(randi_range(1, 3))
				layout2_bridge.get_node("Variation2_2/rewardLabel2_2").text = PlayerInfo.mapValue
				teleporter2 = rewardValue
				
				if (variationID == 3):
					layout2_bridge.get_node("Variation2_3").visible = true
					
					layout2_bridge.get_node("Variation2_2/BoundaryBridge2_2/CollisionPolygon2D").disabled = true
					
					layout2_bridge.get_node("Variation2_3/BoundaryBridge2_3/CollisionPolygon2D").disabled = false
					layout2_bridge.get_node("Variation2_3/TeleporterArea2_3/Teleporter2_3").disabled = false
					
					rewardSet(randi_range(1, 3))
					layout2_bridge.get_node("Variation2_3/rewardLabel2_3").text = PlayerInfo.mapValue
					teleporter3 = rewardValue
			
		if layout3.visible == true:
			layout3.visible = false
			layout3.get_node("Boundary3/CollisionPolygon2D").disabled = true
			layout3_bridge.visible = true
			
			layout3_bridge.get_node("Variation3_1/TeleporterArea3_1/Teleporter3_1").disabled = false
			layout3_bridge.get_node("Variation3_2").visible = false
			layout3_bridge.get_node("Variation3_3").visible = false
			
			#var rewardLabel = layout1_bridge.get_node("rewardLabel")
			rewardSet(randi_range(1, 3))
			layout3_bridge.get_node("Variation3_1/rewardLabel3_1").text = PlayerInfo.mapValue
			teleporter1 = rewardValue
			
			if (variationID == 1):
				layout3_bridge.get_node("Variation3_1/Boundary3_1/CollisionPolygon2D").disabled = false
			
			if (variationID >= 2):
				layout3_bridge.get_node("Variation3_2").visible = true
				
				layout3_bridge.get_node("Variation3_2/Boundary3_2/CollisionPolygon2D").disabled = false
				layout3_bridge.get_node("Variation3_2/TeleporterArea3_2/Teleporter3_2").disabled = false
				
				rewardSet(randi_range(1, 3))
				layout3_bridge.get_node("Variation3_2/rewardLabel3_2").text = PlayerInfo.mapValue
				teleporter2 = rewardValue
				
				if (variationID == 3):
					layout3_bridge.get_node("Variation3_3").visible = true
					
					layout3_bridge.get_node("Variation3_2/Boundary3_2/CollisionPolygon2D").disabled = true
					
					layout3_bridge.get_node("Variation3_3/Boundary3_3/CollisionPolygon2D").disabled = false
					layout3_bridge.get_node("Variation3_3/TeleporterArea3_3/Teleporter3_3").disabled = false
					
					rewardSet(randi_range(1, 3))
					layout3_bridge.get_node("Variation3_3/rewardLabel3_3").text = PlayerInfo.mapValue
					teleporter3 = rewardValue
				
			
