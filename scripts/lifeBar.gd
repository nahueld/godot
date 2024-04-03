extends Polygon2D

signal life_depleted

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func change_life_bar_size(life_bar, change):
	polygon[0].x += change
	polygon[1].x += change

	return polygon

func set_defaults(life_bar):
	if life_bar[0].x > 25:
		life_bar[0].x = 25
		life_bar[1].x = 25
	elif life_bar[0].x < 0:
		life_bar[0].x = 0
		life_bar[1].x = 0
	
	return life_bar
	
func take_damage(damage):
		
	var polygon = get_polygon()
	
	var changed = change_life_bar_size(polygon, -damage)
	var with_defaults = set_defaults(changed)
	set_polygon(with_defaults)
	
	if with_defaults[0].x == 0:
		emit_signal('life_depleted')
		
	return with_defaults[0].x
