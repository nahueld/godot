class_name Fly extends CharacterBody2D

@onready var sprite = $AnimatedSprite2D
@onready var collision_box = $CollisionShape2D
#@onready var free_area: Area2D = $FreeArea

var damage = 5
var shape: Shape2D

enum { PERSUING, FLEEING }

var state = PERSUING

func _ready():

	var variations = [
		Color.DARK_BLUE,
		Color.DARK_OLIVE_GREEN,
		Color.DARK_RED
	]
	
	var colorIdx = randi_range(0, variations.size() - 1)
	sprite.modulate = variations[colorIdx]
	
	shape = collision_box.shape
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var player = get_tree().get_first_node_in_group('player')
	var direction = player.global_position - global_position
	set_velocity(direction * 1.5)
	
	move_and_slide()

#func _on_area_2d_body_entered(body):
	#if body is Fly:
		#print('run...')
		#body.state = FLEEING

#func _on_area_2d_body_exited(body):
	#if body is Fly:
		#body.state = PERSUING
