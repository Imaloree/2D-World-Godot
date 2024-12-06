extends CharacterBody2D

var speed = 40
var player_chase = false
var player = null
var health = 100
var player_in_attack_range = false
var can_take_damage = true
var stop_at_moving = false
var is_hurt = false
var is_dying = false
var is_dead = false

func enemy():
	pass

func _physics_process(_delta: float) -> void:
	deal_with_damage()
	update_healthbar()
	
	if global.goblin_attacking and !is_dying and !is_hurt:
		stop_at_moving = true
		$attacking_cooldown.start()
		$AnimatedSprite2D.play("attack")
	elif is_hurt:
		$AnimatedSprite2D.play("hurt")
	elif is_dying:
		$AnimatedSprite2D.play("death")
	elif !stop_at_moving:
		if player_chase:
			position += (player.position - position) / speed
			$AnimatedSprite2D.play("walk")
			if (player.position.x - position.x) < 0:
				$AnimatedSprite2D.flip_h = true
			else:
				$AnimatedSprite2D.flip_h = false
		else:
			$AnimatedSprite2D.play("idle")
			
	move_and_slide()
	

func _on_detection_area_body_entered(body: Node2D) -> void:
	player = body
	player_chase = true

func _on_detection_area_body_exited(_body: Node2D) -> void:
	player = null
	player_chase = false


func _on_enemy_hitbox_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		player_in_attack_range = true


func _on_enemy_hitbox_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		player_in_attack_range = false

func deal_with_damage():
	if player_in_attack_range and global.player_current_attack == true:
		if health <= 0:
			stop_at_moving = true
			is_dying = true
			$for_death_animation.start()
		if can_take_damage:
			if health > 0:
				health -= 20
				is_hurt = true
				$take_damage_cooldown.start()
				can_take_damage = false
				stop_at_moving = true
				$for_hurt_animation.start()

func _on_take_damage_cooldown_timeout() -> void:
	can_take_damage = true
	stop_at_moving = false

func _on_for_hurt_animation_timeout() -> void:
	is_hurt = false
	stop_at_moving = false

func _on_for_death_animation_timeout() -> void:
	is_dying = false
	is_dead = true
	stop_at_moving = true
	if is_dead:
		self.queue_free()


func _on_attacking_cooldown_timeout() -> void:
	global.goblin_attacking = false
	stop_at_moving = false

func update_healthbar():
	var healthbar = $ghealth_bar
	healthbar.value = health
	
	if health >= 100:
		healthbar.visible = false
	else:
		healthbar.visible = true
