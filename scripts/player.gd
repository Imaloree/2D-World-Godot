extends CharacterBody2D

var enemy_in_attack_range = false
var enemy_attack_cooldown = true
var health = 100
var player_alive = true
var attack_in_progress = false
var stop_at_moving = false
var enemy_attacking = false

var speed = 100.0
var current_dir = "none"

@onready var animate = $AnimatedSprite2D

func player():
	pass

func _ready():
	$AnimatedSprite2D.play("idle_s")

func run_or_walk(shift_key):
	if shift_key:
		speed = 150.0
		play_anim(2)
	else:
		speed = 100.0
		play_anim(1)

func _physics_process(delta):
	update_healthbar()
	player_movement(delta)
	enemy_attack()
	attack()
	
	if health <= 0:
		player_alive = false
		health = 0

func player_movement(_delta):
	var pressed_right = Input.is_action_pressed("right_d")
	var pressed_left = Input.is_action_pressed("left_a")
	var pressed_up = Input.is_action_pressed("up_w")
	var pressed_down = Input.is_action_pressed("down_s")
	var shift_key = Input.is_action_pressed("shift_key")
	
	# if attack_in_progress == false: else: v.x = 0
	if !stop_at_moving:
		if pressed_right and pressed_up:
			current_dir = "ne"
			run_or_walk(shift_key)
			velocity.x = speed
			velocity.y = -speed
		elif pressed_right and pressed_down:
			current_dir = "se"
			run_or_walk(shift_key)
			velocity.x = speed
			velocity.y = speed
		elif pressed_left and pressed_up:
			current_dir = "nw"
			run_or_walk(shift_key)
			velocity.x = -speed
			velocity.y = -speed
		elif pressed_left and pressed_down:
			current_dir = "sw"
			run_or_walk(shift_key)
			velocity.x = -speed
			velocity.y = speed
		elif pressed_right:
			current_dir = "e"
			run_or_walk(shift_key)
			velocity.x = speed
			velocity.y = 0
		elif pressed_left:
			current_dir = "w"
			run_or_walk(shift_key)
			velocity.x = -speed
			velocity.y = 0
		elif pressed_down:
			current_dir = "s"
			run_or_walk(shift_key)
			velocity.y = speed
			velocity.x = 0
		elif pressed_up:
			current_dir = "n"
			run_or_walk(shift_key)
			velocity.y = -speed
			velocity.x = 0
		else:
			play_anim(0)
			velocity.x = 0
			velocity.y = 0
	else:
		velocity.x = 0
		velocity.y = 0
		pass
	move_and_slide()

func play_anim(movement):
	var dir = current_dir
	
	if !stop_at_moving:
		if dir == "n":
			animate.flip_h = false
			if movement == 1:
				animate.play("walk_n")
			elif movement == 2:
				animate.play("run_n")
			else:
				if attack_in_progress == false:
					animate.play("idle_n")
		if dir == "ne":
			animate.flip_h = false
			if movement == 1:
				animate.play("walk_ne")
			elif movement == 2:
				animate.play("run_ne")
			else:
				if attack_in_progress == false:
					animate.play("idle_ne")
		if dir == "e":
			animate.flip_h = false
			if movement == 1:
				animate.play("walk_se")
			elif movement == 2:
				animate.play("run_se")
			else:
				if attack_in_progress == false:
					animate.play("idle_se")
		if dir == "se":
			animate.flip_h = false
			if movement == 1:
				animate.play("walk_se")
			elif movement == 2:
				animate.play("run_se")
			else:
				if attack_in_progress == false:
					animate.play("idle_se")
		if dir == "s":
			animate.flip_h = false
			if movement == 1:
				animate.play("walk_s")
			elif movement == 2:
				animate.play("run_s")
			else:
				if attack_in_progress == false:
					animate.play("idle_s")
		if dir == "sw":
			animate.flip_h = true
			if movement == 1:
				animate.play("walk_se")
			elif movement == 2:
				animate.play("run_se")
			else:
				if attack_in_progress == false:
					animate.play("idle_se")
		if dir == "w":
			animate.flip_h = true
			if movement == 1:
				animate.play("walk_se")
			elif movement == 2:
				animate.play("run_se")
			else:
				if attack_in_progress == false:
					animate.play("idle_se")
		if dir == "nw":
			animate.flip_h = true
			if movement == 1:
				animate.play("walk_ne")
			elif movement == 2:
				animate.play("run_ne")
			else:
				if attack_in_progress == false:
					animate.play("idle_ne")


func _on_player_hitbox_body_entered(body: Node2D) -> void:
	if body.has_method("enemy"):
		enemy_in_attack_range = true

func _on_player_hitbox_body_exited(body: Node2D) -> void:
	if body.has_method("enemy"):
		enemy_in_attack_range = false
		global.goblin_attacking = false

func enemy_attack():
	if enemy_in_attack_range and enemy_attack_cooldown == true:
		enemy_attacking = true
		global.goblin_attacking = true
		if global.goblin_attacking:
			health -= 5
		if health > 0:
			play_hurt_animation()
		else:
			player_alive = false
			play_death_animation()
		enemy_attack_cooldown = false
		$attack_cooldown.start()

func _on_attack_cooldown_timeout() -> void:
	enemy_attack_cooldown = true
	enemy_attacking = false

func attack():
	var dir = current_dir
	
	if Input.is_action_just_pressed("attack"):
		global.player_current_attack = true
		attack_in_progress = true
		
		if dir in ["s", "sw", "w", "nw"]:
			animate.flip_h = true
			animate.play("attack")
		elif dir in ["n", "ne", "e", "se"]:
			animate.flip_h = false
			animate.play("attack")
		
		$deal_attack_timer.start()
		stop_at_moving = true


func _on_deal_attack_timer_timeout() -> void:
	$deal_attack_timer.stop()
	global.player_current_attack = false
	attack_in_progress = false
	stop_at_moving = false

func play_hurt_animation():
	animate.play("hurt") 
	stop_at_moving = true

func play_death_animation():
	animate.play("death")
	stop_at_moving = true


func update_healthbar():
	var healthbar = $healthbar
	healthbar.value = health
	
	if health >= 100:
		healthbar.visible = false
	else:
		healthbar.visible = true

func _on_regen_timer_timeout() -> void:
	if health < 100:
		health += 20
		if health > 100:
			health = 100
	if health <= 0:
		health = 0
		
