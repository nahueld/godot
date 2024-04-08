class_name Player extends CharacterBody2D

signal projectile_shot(p)

@onready var life_bar: LifeBar = $LifeBar

@onready var idle_sprite: AnimatedSprite2D = $Idle
@onready var run_sprite: AnimatedSprite2D = $Run
@onready var jump_sprite: AnimatedSprite2D = $Jump

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var area: Area2D = $Area2D

const SPEED = 200.0
const JUMP_VELOCITY = -300.0
const THROW_FORCE = -400
const INVINCIBILITY_SPAN = 0.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var collisions: Dictionary = {}
var projectileScene = preload("res://scenes/projectile.tscn")

var pos_y = global_position.y

func _ready():
	run_sprite.play()
	jump_sprite.play()
	idle_sprite.play()
	
	idle_sprite.hide()
	run_sprite.hide()
	jump_sprite.hide()
	
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
	play_jumping_animation()
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		jump_sprite.hide()

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
		
	if Input.is_action_just_pressed("ui_up"):
		var p = projectileScene.instantiate()
		
		p.global_position = position
		p.xSpeed = -1 if idle_sprite.flip_h == false else 1
		p.ySpeed = THROW_FORCE
		emit_signal("projectile_shot", p)
		
	if Input.is_action_just_pressed('attack'):
		print('pressed')
		

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		if is_on_floor():
			idle_sprite.hide()
			run_sprite.show()
			
			if velocity.x > 0:
				run_sprite.set_flip_h(false)
			elif velocity.x < 0:
				run_sprite.set_flip_h(true)	
			#if has_to_unflip:
				#run_sprite.set_flip_h(false)
				
			velocity.x = direction * SPEED
		else:
			idle_sprite.hide()
			run_sprite.hide()
	else:
		if velocity.x > 0:
			idle_sprite.set_flip_h(false)
		elif velocity.x < 0:
			idle_sprite.set_flip_h(true)
			
		velocity.x = move_toward(velocity.x, 0, SPEED)
		run_sprite.hide()
		#idle_sprite.show()
	
	move_and_slide()

func on_life_reduced(damage):
	var tween = create_tween()
	
	var current_modulate = idle_sprite.modulate
	
	for n in 4:
		var modulate_to = current_modulate if n % 2 else Color.RED 
		tween.tween_property(idle_sprite, 'modulate', modulate_to, 0.1)
	
func _on_screen_exit():
	print('y se marcho :(')
	queue_free()

var previous_height = global_position.y

func play_jumping_animation():
	if is_on_floor():
		return
	
	print('previous_height', previous_height)
	var is_rising = previous_height > global_position.y
	var is_falling = previous_height < global_position.y
	
	var difference = global_position.y - previous_height
	var rounded = roundi(difference)
	print('rounded ', rounded)

	if rounded == 0:
		jump_sprite.set_frame(1)
	elif is_rising:
		jump_sprite.set_frame(0)
	elif is_falling:
		jump_sprite.set_frame(2)

	previous_height = global_position.y
	jump_sprite.pause()
	jump_sprite.show()
