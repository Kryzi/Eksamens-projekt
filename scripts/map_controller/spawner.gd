extends Node2D

@export var enemy_1: PackedScene
@export var enemy_1_1: PackedScene
@export var enemy_2: PackedScene
@export var enemy_2_2: PackedScene
@export var enemy_3: PackedScene
@export var enemy_4: PackedScene
@export var enemy_5: PackedScene
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

var min_obstacle_spacing: int = 500
var enemy_and_obstacle_starting_positions: Array[Vector2]
var max_single_obstacle_generation_attempts: int = 5
var obstacleArea: Rect2
var obstacleAreaPolygon: PackedVector2Array

var spawnArea: Rect2
var rewardValue: int = 0

var teleporter1 = 0
var teleporter2 = 0
var teleporter3 = 0
var teleporterShop = 0
var variationID = 0

func _ready() -> void:
	create_spawn_area(boundary)
	generate_obstacles(obstacle_boundary)

#region Obstacle generation
func generate_obstacles(new_obstacle_boundary: CollisionPolygon2D) -> void:
	obstacleAreaPolygon = get_obstacle_area_polygon(new_obstacle_boundary)
	obstacleArea = get_area_from_boundary(new_obstacle_boundary)
	
	var amountObstacle = randi_range(10, 15)
	enemy_and_obstacle_starting_positions = []
	for i in amountObstacle:
		random_obstacle_generation()
		
	call_deferred("awaited_navigation_region_baking")

func awaited_navigation_region_baking() -> void:
	await get_tree().physics_frame
	navigation_region.bake_navigation_polygon()

func get_obstacle_area_polygon(collision_polygon: CollisionPolygon2D) -> PackedVector2Array:
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
			enemy_and_obstacle_starting_positions.append(pos)
			call_deferred("add_child", obstacle_instance)
			break

func is_obstacle_position_valid(new_pos: Vector2) -> bool:
	for obstacle_position in enemy_and_obstacle_starting_positions:
		if obstacle_position.distance_to(new_pos) < min_obstacle_spacing:
			return false
	return true
#endregion Obstacle generation

#region Enemy spawning
#Amount er for normale modstandere, amount2 er for stærke modstandere
var amount = 0
var amount2 = 0
var enemy_scenes = []
func create_spawn_area(new_boundary):
	spawnArea = get_area_from_boundary(new_boundary)
	if (PlayerInfo.bossTimer <= 5):
		amount = randi_range(2, 3)
	if (PlayerInfo.bossTimer >= 4):
		amount2 = 1
	if (PlayerInfo.bossTimer <= 9 and PlayerInfo.bossTimer > 5):
		amount = randi_range(2, 4)
		amount2 = randi_range(2, 3)
	if (PlayerInfo.bossTimer >= 9):
		amount = randi_range(4, 6)
		amount2 = randi_range(3, 4)
	
	if (PlayerInfo.areaID == 1):
		MeleeBoundary = layout1.get_node("EnemyArea1/SpawnShape1")
	if (PlayerInfo.areaID == 2):
		MeleeBoundary = layout2.get_node("EnemyArea2/SpawnShape2")
	if (PlayerInfo.areaID == 3):
		MeleeBoundary = layout3.get_node("EnemyArea3/SpawnShape3")
	
	for i in range(amount):
		random_spawn(i)
	for i in range(amount2):
		strong_spawn(i)
	
func get_area_from_boundary(boundary_for_spawn_area: CollisionPolygon2D) -> Rect2:
	var min_x = INF
	var min_y = INF
	var max_x = -INF
	var max_y = -INF
	
	for point in boundary_for_spawn_area.polygon:
		var global_point = boundary_for_spawn_area.to_global(point)
		min_x = min(min_x, global_point.x)
		min_y = min(min_y, global_point.y)
		max_x = max(max_x, global_point.x)
		max_y = max(max_y, global_point.y)

	return Rect2(Vector2(min_x, min_y), Vector2(max_x - min_x, max_y - min_y))

@onready var MeleeBoundary: CollisionShape2D = layout1.get_node("EnemyArea1/SpawnShape1")
var pos2 
func melee_spawn():
	var rect_shape := MeleeBoundary.shape as RectangleShape2D
	var size = rect_shape.size

	var x2 = randf_range(-size.x / 2, size.x / 2)
	var y2 = randf_range(-size.y / 2, size.y / 2)
	var local_pos = Vector2(x2, y2)
	pos2 = MeleeBoundary.global_position + local_pos

func random_spawn(i):
	var x = randf_range(spawnArea.position.x, spawnArea.end.x)
	var y = randf_range(spawnArea.position.y, spawnArea.end.y)
	var pos = Vector2(x, y)
	
	melee_spawn()
	
	#Første modstander er altid basis
	if (i == 0):
		var enemy_instance = enemy_1.instantiate()
		enemy_instance.position = pos
		enemy_and_obstacle_starting_positions.append(pos)
		call_deferred("add_child", enemy_instance)
	else:
		enemy_scenes = []
		#Vælg en tilfældig fjende at spawne
		if (PlayerInfo.bossTimer <= 3):
			enemy_scenes = [enemy_1, enemy_3]
		elif (PlayerInfo.bossTimer >= 4):
			enemy_scenes = [enemy_1, enemy_2, enemy_3]
		elif (PlayerInfo.bossTimer >= 9):
			enemy_scenes = [enemy_1_1, enemy_1, enemy_2, enemy_2_2, enemy_3]
		var selected_enemy = enemy_scenes[randi() % enemy_scenes.size()]
		
		var enemy_instance = selected_enemy.instantiate()
		#Modstander 3 spawner tættere til spilleren
		if(selected_enemy == enemy_3 or selected_enemy == enemy_2_2):
			enemy_instance.position = pos2
			enemy_and_obstacle_starting_positions.append(pos2)
		else:
			enemy_instance.position = pos
			enemy_and_obstacle_starting_positions.append(pos)
		call_deferred("add_child", enemy_instance)
		#print("used2")

#For de stærke modstandere der skal være færre af
func strong_spawn(i):
	var x = randf_range(spawnArea.position.x, spawnArea.end.x)
	var y = randf_range(spawnArea.position.y, spawnArea.end.y)
	var pos = Vector2(x, y)
	melee_spawn()
	
	#Første modstander er altid basis
	if (i == 0):
		var enemy_instance = enemy_1.instantiate()
		enemy_instance.position = pos
		call_deferred("add_child", enemy_instance)
		#print("used")
	else:
		enemy_scenes = []
		
		enemy_scenes = [enemy_2_2, enemy_5, enemy_1_1]
		if (PlayerInfo.bossTimer >= 9):
			enemy_scenes = [enemy_1_1, enemy_5, enemy_2_2, enemy_4]
			'print("brugt")'
		var selected_enemy = enemy_scenes[randi() % enemy_scenes.size()]
		
		var enemy_instance = selected_enemy.instantiate()
		if(selected_enemy == enemy_5 or selected_enemy == enemy_2_2 or selected_enemy == enemy_4 ):
			enemy_instance.position = pos2
			enemy_and_obstacle_starting_positions.append(pos2)
		else:
			enemy_instance.position = pos
			enemy_and_obstacle_starting_positions.append(pos)
		call_deferred("add_child", enemy_instance)

func elite_spawn(_i):
	var x = randf_range(spawnArea.position.x, spawnArea.end.x)
	var y = randf_range(spawnArea.position.y, spawnArea.end.y)
	var pos = Vector2(x, y)
	melee_spawn()
	#Første modstander er altid basis
	if (randi_range(1,2) == 2):
		var enemy_instance = enemy_2_2.instantiate()
		enemy_instance.position = pos
		call_deferred("add_child", enemy_instance)
	else: 
		
		enemy_scenes = [enemy_1_1, enemy_5, enemy_2_2]
		if (PlayerInfo.bossTimer >= 5):
			enemy_scenes = [enemy_1_1, enemy_5, enemy_2_2, enemy_4]
		if (PlayerInfo.bossTimer >= 9):
			enemy_scenes = [enemy_5, enemy_4]
		
		var selected_enemy = enemy_scenes[randi() % enemy_scenes.size()]
		
		var enemy_instance = selected_enemy.instantiate()
		if(selected_enemy == enemy_3 or selected_enemy == enemy_4 or selected_enemy == enemy_2_2 or selected_enemy == enemy_5):
			enemy_instance.position = pos2
		else:
			enemy_instance.position = pos
		call_deferred("add_child", enemy_instance)
#endregion Enemy Spawning

func rewardSet(value):
	var eliteChance = 0
	if (PlayerInfo.bossTimer >= 4):
		eliteChance = randi_range(1, 3)
	if (PlayerInfo.bossTimer >= 9):
		eliteChance = randi_range(2, 3)
	if (PlayerInfo.areaID == 0):
		eliteChance = 0
	
	rewardValue = value
	if (rewardValue == 1 or rewardValue == 4):
		PlayerInfo.mapValue = "Coins"
	if (rewardValue == 2 or rewardValue == 5):
		PlayerInfo.mapValue = "Item" 
	if (eliteChance == 3 and (rewardValue == 1 or rewardValue == 2) or rewardValue > 3):
		PlayerInfo.mapValue = ("Elite " + PlayerInfo.mapValue)
		rewardValue += 3
	if (rewardValue == 3):
		PlayerInfo.mapValue = "Shop"
	if (PlayerInfo.bossTimer == 14):
		PlayerInfo.mapValue = "Boss"

@export var item: PackedScene


func stageReward(Reward):
	if Reward == 1:
		PlayerInfo.current_coins += 15
	if Reward == 2:
		getItem()
	if Reward == 3:
		pass #Værdien bliver brugt i map_controller
	if Reward == 4:
		PlayerInfo.current_coins += 30
	if Reward == 5:
		getItem()
		getItem()

func getItem():
	boundary = get_node("/root/Main/MapController/Background/Layout1/EnemyArea1/SpawnPolygon1")
	#Find areaID
	match PlayerInfo.areaID:
		1:
			boundary = get_node("/root/Main/MapController/Background/Layout1/EnemyArea1/SpawnPolygon1")
		2:
			boundary = get_node("/root/Main/MapController/Background/Layout2/EnemyArea2/SpawnPolygon2")
		3:
			boundary = get_node("/root/Main/MapController/Background/Layout3/EnemyArea3/SpawnPolygon3")
	#Skab tilfældigt item
	var itemInstance = item.instantiate()
	itemInstance.itemGenerator()
	#Teleportere tilfældigt item til midten af boundry
	spawnArea = get_area_from_boundary(boundary)
	var x = randf_range(spawnArea.position.x, spawnArea.end.x)
	var y = randf_range(spawnArea.position.y, spawnArea.end.y)
	var pos = Vector2(x, y)
	itemInstance.position = pos
	call_deferred("add_child", itemInstance)

func stageRig():
	# Baner er farligere i enden (flere elites), så der skabes flere valg-muligheder
	if (PlayerInfo.bossTimer >= 9):
		variationID = randi_range(2, 3)
	#Sikre at der næsten altid er mindst en vej der ikke er shop
	rewardSet(randi_range(1, 2))
	#Sikre at man får en shop mindst vær tredje bane og lige før bosskampen
	if ((PlayerInfo.bossTimer % 3) == 0 and PlayerInfo.bossTimer > 0 and PlayerInfo.bossTimer < 10 or PlayerInfo.bossTimer < 11):
		rewardSet(3)
	if (PlayerInfo.bossTimer > 12):
		rewardSet(3)
		variationID = 1
		
	#Sikre at man alitd for coins i starten
	if (PlayerInfo.bossTimer < 3):
		rewardSet(1)

func layoutController(layoutX: int, layout: Node, layout_bridge: Node):
	layout.visible = false
	layout.get_node("Boundary%d/CollisionPolygon2D" % [layoutX]).disabled = true
	layout_bridge.visible = true
	
	layout_bridge.get_node("Variation%d_1/TeleporterArea%d_1/Teleporter%d_1" % [layoutX, layoutX, layoutX]).disabled = false
	layout_bridge.get_node("Variation%d_2" % [layoutX]).visible = false
	layout_bridge.get_node("Variation%d_3" % [layoutX]).visible = false
	
	layout_bridge.get_node("Variation%d_1/rewardLabel%d_1" % [layoutX, layoutX]).text = PlayerInfo.mapValue
	layout_bridge.get_node("Variation%d_1/rewardIcon" % [layoutX]).play(PlayerInfo.mapValue)
	teleporter1 = rewardValue
	
	if (variationID == 1):
		layout_bridge.get_node("Variation%d_1/BoundaryBridge%d_1/CollisionPolygon2D" % [layoutX, layoutX]).disabled = false
	
	if (variationID >= 2):
		layout_bridge.get_node("Variation%d_2" % [layoutX]).visible = true
		
		layout_bridge.get_node("Variation%d_2/BoundaryBridge%d_2/CollisionPolygon2D" % [layoutX, layoutX]).disabled = false
		layout_bridge.get_node("Variation%d_2/TeleporterArea%d_2/Teleporter%d_2" % [layoutX, layoutX, layoutX]).disabled = false
		
		rewardSet(randi_range(1, 3))
		if (PlayerInfo.bossTimer == 12):
			rewardSet(randi_range(1, 2))
		layout_bridge.get_node("Variation%d_2/rewardLabel%d_2" % [layoutX, layoutX]).text = PlayerInfo.mapValue
		layout_bridge.get_node("Variation%d_2/rewardIcon" % [layoutX]).play(PlayerInfo.mapValue)
		
		teleporter2 = rewardValue
		
		if (variationID == 3):
			layout_bridge.get_node("Variation%d_3" % [layoutX]).visible = true
			
			layout_bridge.get_node("Variation%d_2/BoundaryBridge%d_2/CollisionPolygon2D" % [layoutX, layoutX]).disabled = true
			
			layout_bridge.get_node("Variation%d_3/BoundaryBridge%d_3/CollisionPolygon2D" % [layoutX, layoutX]).disabled = false
			layout_bridge.get_node("Variation%d_3/TeleporterArea%d_3/Teleporter%d_3" % [layoutX, layoutX, layoutX]).disabled = false
			
			rewardSet(randi_range(1, 3))
			if (PlayerInfo.bossTimer == 12):
				rewardSet(randi_range(1, 2))
			layout_bridge.get_node("Variation%d_3/rewardLabel%d_3" % [layoutX, layoutX]).text = PlayerInfo.mapValue
			layout_bridge.get_node("Variation%d_3/rewardIcon" % [layoutX]).play(PlayerInfo.mapValue)
			teleporter3 = rewardValue


func checkDeath():
	await get_tree().process_frame
	if get_tree().get_nodes_in_group("enemy").is_empty():
		var Reward = map_controller.stageReward
		stageReward(Reward)
		variationID = randi_range(1, 3)
		
		#Sikre at baner ikke er helt tilfældige
		stageRig()
		
		if layout1.visible:
			layoutController(1, layout1, layout1_bridge)
		elif layout2.visible:
			layoutController(2, layout2, layout2_bridge)
		elif layout3.visible:
			layoutController(3, layout3, layout3_bridge)
		

func checkNextShopStage():
	rewardValue = randi_range(1, 2)
	if (PlayerInfo.bossTimer >= 4 and randi_range(1, 2) == 3 ):
		rewardValue += 3
	if (PlayerInfo.bossTimer >= 9 and randi_range(2, 3) == 3 ):
		rewardValue += 3
	rewardSet(rewardValue)
	layout1_bridge_shop.get_node("rewardLabel").text = PlayerInfo.mapValue
	layout1_bridge_shop.get_node("rewardIcon").play(PlayerInfo.mapValue)
	
	var teleporter_collision1_shop = layout1_bridge_shop.get_node("TeleporterArea1/Teleporter1")
	teleporter_collision1_shop.call_deferred("set_disabled", false)
	
	teleporterShop = rewardValue
	
	
