class_name Player extends CharacterBody2D

signal projectile_shot(p)

@onready var life_bar: LifeBar = $LifeBar

@onready var idle_sprite: AnimatedSprite2D = $Idle
@onready var run_sprite: AnimatedSprite2D = $Run
@onready var jump_sprite: AnimatedSprite2D = $Jump
@onready var attack_sprite: AnimatedSprite2D = $Attack

@onready var all_sprites = [idle_sprite, run_sprite, jump_sprite, attack_sprite]

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var area: Area2D = $Area2D

const SPEED = 200.0
const JUMP_VELOCITY = -350.0
const THROW_FORCE = -400
const INVINCIBILITY_SPAN = 0.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var collisions: Dictionary = {}
var in_slash_range: Dictionary = {}

var projectileScene = preload("res://scenes/projectile.tscn")

var pos_y = global_position.y

# jump
var jump_started = false
var previous_height = global_position.y

# attack
var attack_started = false

func _ready():
	for s in all_sprites:
		if s != attack_sprite:
			s.play()
		s.hide()
	
	life_bar.invincibility_span = INVINCIBILITY_SPAN
	life_bar.connect('life_reduced', on_life_reduced)
	area.connect('body_entered', on_body_entered)
	area.connect('body_exited', on_body_exited)
	
	pos_y = global_position.y
	
func on_body_entered(b):
	if b is Fly:
		var key = b.get_instance_id()
		var value = b
		collisions[key] = value
		
func on_body_exited(b):
	if b is Fly:
		var r = collisions.erase(b.get_instance_id())

func _process(delta):
	if(!collisions.is_empty()):
		var values = collisions.values()
		for v in values:
			life_bar.change_life(-v.damage)

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		idle_sprite.hide()
		play_jumping_animation()
		velocity.y += gravity * delta
		
	if is_on_floor():
		if attack_started:
			idle_sprite.hide()
			jump_sprite.hide()
		else:
			jump_sprite.hide()
			idle_sprite.show()

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	if Input.is_action_just_pressed("ui_up"):
		var p = projectileScene.instantiate()
		
		p.global_position = position
		p.xSpeed = -1 if idle_sprite.flip_h == false else 1
		p.ySpeed = THROW_FORCE
		emit_signal("projectile_shot", p)
		
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("ui_left", "ui_right")
	
	if direction && not attack_started:
		if is_on_floor():
			idle_sprite.hide()
			run_sprite.show()
			
			set_flip(run_sprite)
				
			velocity.x = direction * SPEED
		else:
			idle_sprite.hide()
			run_sprite.hide()
	else:
		set_flip(idle_sprite)
		velocity.x = move_toward(velocity.x, 0, SPEED)
		run_sprite.hide()
		if not attack_started:
			idle_sprite.show()
		else:
			idle_sprite.hide()
			
	if Input.is_action_just_pressed('attack') && is_on_floor() && not direction:
		play_attack_animation()
	
	if attack_sprite.frame == 4:
		attack_started = false
		attack_sprite.stop()
		attack_sprite.frame = 0
		attack_sprite.hide()
	
	move_and_slide()

func on_life_reduced(damage):
	var tween = create_tween()
	
	for s in all_sprites:
		if s.visible:
			var current_modulate = s.modulate
		
			for n in 4:
				var modulate_to = current_modulate if n % 2 else Color.RED 
				tween.tween_property(s, 'modulate', modulate_to, 0.1)
	
func _on_screen_exit():
	print('y se marcho :(')
	queue_free()
	
func set_flip(sprite):
	if velocity.x > 0:
		sprite.set_flip_h(false)
	elif velocity.x < 0:
		sprite.set_flip_h(true)
		
func play_attack_animation():
	if attack_started:
		return
		
	for s in all_sprites:
		s.hide()
		
	attack_started = true
	attack_sprite.flip_h = idle_sprite.flip_h
	
	if attack_sprite.flip_h:
		attack_sprite.position = Vector2(-92,-52)
	else:
		attack_sprite.position = Vector2(-34,-52)
			
	attack_sprite.play()
	attack_sprite.show()
	
	for b in in_slash_range.values():
		print('global_position', global_position.x)
		print('fly', b.global_position.x)
		if attack_sprite.flip_h && global_position.x > b.global_position.x:
			b.queue_free()
		elif not attack_sprite.flip_h && global_position.x < b.global_position.x:
			b.queue_free()

func play_jumping_animation():
	if is_on_floor():
		if jump_started:
			jump_started = false
			idle_sprite.show()
		return
	
	idle_sprite.hide()
	jump_started = true
	
	set_flip(jump_sprite)
	var is_rising = previous_height > global_position.y
	var is_falling = previous_height < global_position.y
	
	var difference = global_position.y - previous_height
	var rounded = roundi(difference)

	if rounded == 0:
		jump_sprite.set_frame(1)
	elif is_rising:
		jump_sprite.set_frame(0)
	elif is_falling:
		jump_sprite.set_frame(2)

	previous_height = global_position.y
	jump_sprite.pause()
	jump_sprite.show()

func on_body_entered_to_slash(body):
	if body is Fly:
		var key = body.get_instance_id()
		var value = body
		in_slash_range[key] = body
	
func on_body_exited_slash(body):
	in_slash_range.erase(body.get_instance_id())
