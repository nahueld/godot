class_name Player extends CharacterBody2D

signal projectile_shot(p)

@onready var life_bar: LifeBar = $LifeBar
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
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

func _ready():
	life_bar.invincibility_span = INVINCIBILITY_SPAN
	life_bar.connect('life_reduced', on_life_reduced)
	area.connect('body_entered', on_body_entered)
	area.connect('body_exited', on_body_exited)
	
func on_body_entered(b):
	if b is Fly:
		var key = b.get_instance_id()
		var value = b
		collisions[key] = value
		
func on_body_exited(b):
	if b is Fly:
		print('fly leaves')
		var r = collisions.erase(b.get_instance_id())
		print('result is ', r)

func _process(delta):
	if(!collisions.is_empty()):
		var values = collisions.values()
		for v in values:
			life_bar.change_life(-v.damage)

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	if Input.is_action_just_pressed("ui_up"):
		var p = projectileScene.instantiate()
		
		p.global_position = position
		p.xSpeed = -1 if sprite.flip_h == false else 1
		p.ySpeed = THROW_FORCE
		emit_signal("projectile_shot", p)

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		sprite.play()
		
		var has_to_flip = velocity.x > 0 && sprite.flip_h == false
		var has_to_unflip = velocity.x < 0 && sprite.flip_h == true
		
		if has_to_flip:
			sprite.set_flip_h(true)
			
		if has_to_unflip:
			sprite.set_flip_h(false)
			
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		sprite.stop()
	
	move_and_slide()

func on_life_reduced(damage):
	var tween = create_tween()
	
	var current_modulate = sprite.modulate
	
	for n in 4:
		var modulate_to = current_modulate if n % 2 else Color.RED 
		tween.tween_property(sprite, 'modulate', modulate_to, 0.1)
	
func _on_screen_exit():
	print('y se marcho :(')
	queue_free()
