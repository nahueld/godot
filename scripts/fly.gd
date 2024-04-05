class_name Fly extends CharacterBody2D

@onready var sprite = $AnimatedSprite2D
@onready var collision_box = $CollisionShape2D
#@onready var free_area: Area2D = $FreeArea

var damage = 5

func _ready():
	#free_area.connect('body_entered', on_body_entered)
	var variations = [
		Color.DARK_BLUE,
		Color.DARK_OLIVE_GREEN,
		Color.DARK_RED
	]
	
	var colorIdx = randi_range(0, variations.size() - 1)
	sprite.modulate = variations[colorIdx]
	
#func on_body_entered(n: Node2D):
	#if n is Fly:
		#print('its another fly')	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var player = get_tree().get_first_node_in_group('player')
	
	var direction = player.global_position - global_position
	
	set_velocity(direction)
	
	move_and_slide()
			
			
