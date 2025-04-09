extends CharacterBody2D

var theta: float = 0.0
var speed: float = 125.0  
var target_position: Vector2  
var retning: String = "ned"  # Standard retning
var is_thinking: bool = false  # Forhindrer gentagne bevægelseskald
var attacking = false

@export var thinkTime = 1.0 
@export var health = 600
@export var bullet_scene: PackedScene
@export_range(0, 2 * PI) var alpha: float = 0.0
@export var trampDonwTime = 1.0
@export var  gigaged_lorteprojektil_texture: Texture2D
@export var gigaged_jord_projektil_texture: Texture2D
@export var coin_scene: PackedScene

@onready var GedeStompSound = $GedeStompSound
@onready var GedeFartSound = $GedeFartSound
@onready var bosslivbar = get_node("/root/Main/HUD/Control/BossLivbar")

func _ready() -> void:
	set_new_target()
	bosslivbar.max_value = health
	bosslivbar.value = health

func _physics_process(_delta):
	if is_thinking == true or attacking == true:
		velocity = Vector2.ZERO  # Stopper bevægelsen, mens fjenden tænker
		move_and_slide()
		return
	
	# Bevæg mod den aktuelle target_position
	var direction = (target_position - position).normalized()
	velocity = direction * speed
	move_and_slide()

	
	# Opdater retning baseret på bevægelsen
	update_retning(direction)
	
	$Krop.play("Walk " + retning)
	$Hoved.play("Idle " + retning)
	
	#print("Global pos:", global_position, "Target pos:", target_position, "Distance:", global_position.distance_to(target_position)) #debug
	
	# Hvis fjenden er tæt på målet, gå i "thinking mode"
	if global_position.distance_to(target_position) < 10 and is_thinking == false and attacking == false:
		is_thinking = true  # Forhindrer flere gentagne kald
		think_and_decide()

func think_and_decide():
	$Krop.play("Idle " + retning)
	$Hoved.play("Idle " + retning)
	
	await get_tree().create_timer(thinkTime).timeout
	
	var randomMove = randi_range(0, 2)
	
	if randomMove == 0:
		set_new_target()  # Vælg en ny destination
	elif randomMove == 1:
		trampAngreb(theta)
	elif randomMove == 2:
		skideAngreb()
	
	is_thinking = false  # Tillad bevægelse igen

func set_new_target():
	# Vælg en tilfældig global position
	var min_x = 950
	var max_x = 2260
	var min_y = 1050
	var max_y = 1800
	
	target_position = Vector2(randi_range(min_x, max_x), randi_range(min_y, max_y))
	#print("Ny target position:", target_position) #debug

func update_retning(direction: Vector2):
	if abs(direction.x) > abs(direction.y): 
		if direction.x > 0:
			retning = "hojre"  # cringe at der ikke er ø
			$CollisionShape2D.shape.size.x = 144
			$CollisionShape2D.shape.size.y = 126
		else:
			retning = "venstre"
			$CollisionShape2D.shape.size.x = 144
			$CollisionShape2D.shape.size.y = 126
	else:
		retning = "ned"
		$CollisionShape2D.shape.size.x = 75
		$CollisionShape2D.shape.size.y = 129


func hit_damage(damage):
	health -= damage
	bosslivbar.value = health
	
	if (health <= 400):
		trampDonwTime = 0.75
		thinkTime = 0.75
		speed = 150
	if (health <= 200):
		trampDonwTime = 0.5
		thinkTime = 0.25 
		speed = 300
	if health <= 0:
		die()

func die():
	dropCoin()
	var high_score = PlayerInfo.timer
	PlayerInfo.win_screen_reached.emit(true, high_score)
	queue_free()

func dropCoin() -> void:
	var coin_instance = coin_scene.instantiate()
	coin_instance.global_position = global_position
	get_tree().get_root().call_deferred("add_child", coin_instance)
	
func skideAngreb():
	attacking = true
	
	var playerpos = get_node("/root/Main/Player").global_position
	update_retning(playerpos)
	GedeFartSound.play()
	
	# Affyr flere kugler i hurtig rækkefølge
	var num_shots = randi_range(15, 30)  # Antal skud
	var shot_delay = 0.05  # Forsinkelse mellem skud
	
	$Krop.play("Skide Angreb " + retning)
	$Hoved.play("Angreb " + retning)
	
	if retning == "ned":
		$skidePos.position = Vector2(2, -42)
	elif retning == "venstre":
		$skidePos.position = Vector2(-43, -37)
	elif retning == "hojre":
		$skidePos.position = Vector2(61, -29)
	
	
	
	
	for i in range(num_shots):
		playerpos = get_node("/root/Main/Player").global_position
		update_retning(playerpos)
		
		var offset = Vector2(randf_range(-250, 250), randf_range(-250, 250))
		var skudDirection = (playerpos - $skidePos.global_position + offset).normalized()
		
		
		var bullet_instance = bullet_scene.instantiate()
		
		bullet_instance.get_child(0).texture =  gigaged_lorteprojektil_texture
		bullet_instance.get_child(1).shape.radius = 22
		bullet_instance.get_child(1).position = Vector2(-2,-10)
		
		bullet_instance.position = $skidePos.global_position
		bullet_instance.direction = skudDirection
		get_tree().get_root().call_deferred("add_child", bullet_instance)
		await get_tree().create_timer(shot_delay).timeout  # Vent lidt mellem skud
	
	
	
	attacking = false




func get_vector(angle):
	theta = angle + alpha
	return Vector2(cos(theta), sin(theta))

func trampAngreb(angle): 
	var num_bullets
	attacking = true
	
	
	for num in 3:
		$Krop.play("Trampe Angreb " + retning)
		$Hoved.play("Trampe Angreb " + retning)
		
		if retning == "ned":
			$trampPos.position = Vector2(3, 49)
		elif retning == "venstre":
			$trampPos.position = Vector2(-48, 46)
		elif retning == "hojre":
			$trampPos.position = Vector2(55, 44)
		
		await $Krop.animation_finished
		await $Hoved.animation_finished
		
		get_node("/root/Main/HUD").NOISE_SHAKE_STRENGTH = 100.0
		get_node("/root/Main/HUD").apply_noise_shake()
		get_node("/root/Main/HUD").NOISE_SHAKE_STRENGTH = 15.0
		
		if num == 0:
			GedeStompSound.play()
			num_bullets = 10
			if (health <= 200):
				num_bullets = 16
			
		elif num == 1:
			GedeStompSound.play()
			num_bullets = 16
			if (health <= 200):
				num_bullets = 24
		elif num == 2:
			GedeStompSound.play()
			num_bullets = 24
			if (health <= 200):
				num_bullets = 32
		
		for i in range(num_bullets):
			var bullet_instance = bullet_scene.instantiate()
			
			bullet_instance.get_child(0).texture = gigaged_jord_projektil_texture
			bullet_instance.get_child(1).shape.radius = 37
			bullet_instance.get_child(1).position = Vector2(0,0)
			
			bullet_instance.position = $trampPos.global_position
			var bullet_angle = angle + (i * 2 * PI / num_bullets)
			bullet_instance.direction = get_vector(bullet_angle)
			get_tree().get_root().call_deferred("add_child", bullet_instance)
		
		await get_tree().create_timer(trampDonwTime).timeout
	
	attacking = false
