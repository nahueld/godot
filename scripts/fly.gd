class_name Fly extends CharacterBody2D

@onready var sprite = $AnimatedSprite2D

const IDENTIFIER = "fly"

var damage = 5

func _ready():
	print(sprite)
	var variations = [
		Color.DARK_BLUE,
		Color.DARK_OLIVE_GREEN,
		Color.DARK_RED,
		Color.BLACK
	]
	
	var colorIdx = randi_range(0, variations.size() - 1)
	sprite.modulate = variations[colorIdx]  

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var player = get_tree().get_first_node_in_group('player')
	
	var direction = player.global_position - global_position
	set_velocity(direction)
	move_and_slide()
			
			
