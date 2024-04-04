extends Line2D

signal life_depleted

var tween : Tween

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func change_life_bar_size(life_bar: Vector2, change: float) -> Vector2:
	life_bar.x += change
	return life_bar

func set_defaults(life_bar: Vector2) -> Vector2:
	if life_bar.x > 25:
		life_bar.x = 25
	elif life_bar.x < 0:
		life_bar.x = 0
	
	return life_bar
	
func take_damage(damage):
		
	var lifeBarEndPoint: Vector2 = get_point_position(1)
	
	var changed: Vector2 = change_life_bar_size(lifeBarEndPoint, -damage)
	var with_defaults: Vector2 = set_defaults(changed)
	
	if tween == null:
		tween = create_tween()
		#tween.custom_step(1)
		tween.set_trans(Tween.TRANS_ELASTIC)
	
	var callback = func (vector: Vector2):
		print('calling', vector)
		set_point_position(1, vector)
	
	tween.tween_method(callback, lifeBarEndPoint, with_defaults, 0.5)
	#tween.tween_callback(func(): self.set_point_position(1, with_defaults))

	tween = null
	
	if with_defaults.x == 0:
		emit_signal('life_depleted')
	
	return with_defaults.x
