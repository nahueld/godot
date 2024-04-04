class_name Player extends CharacterBody2D

signal projectile_shot(p)

@onready var life_bar: LifeBar = $LifeBar
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

const SPEED = 200.0
const JUMP_VELOCITY = -300.0
const THROW_FORCE = -400
const INVINCIBILITY_SPAN = 0.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var projectileScene = preload("res://scenes/projectile.tscn")

func _ready():
	life_bar.invincibility_span = INVINCIBILITY_SPAN
	life_bar.connect('life_reduced', on_life_reduced)

func _process(delta):
	process_collision()
		
	if Input.is_action_just_pressed("ui_up"):
		var p = projectileScene.instantiate()
		p.global_position = position
		p.xSpeed = velocity.x
		p.ySpeed = THROW_FORCE
		emit_signal("projectile_shot", p)
		
func process_collision():
	var collision = get_last_slide_collision()
	
	if collision == null:
		return
		
	var collider = collision.get_collider()
	
	if collider == null:
		return
		
	if(collider is Fly):
		#do fly stuff
		var damage = collider.damage
		
		if damage == null || damage == 0:
			return
		
		life_bar.change_life(-damage)
			
	else:
		return

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		sprite.play()
		sprite.set_flip_h(velocity.x > 0)
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
