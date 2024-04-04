class_name LifeBar extends Line2D

signal life_depleted
signal life_reduced
signal life_increased

var max_life = 25
var min_life = 0
var is_invincible = false
var invincibility_span = 0.5
var tween : Tween

func _ready():
	pass 

func _process(delta):
	pass
	
func change_life_bar_size(life_bar: Vector2, change: float) -> Vector2:
	life_bar.x += change
	return life_bar

func set_defaults(life_bar: Vector2) -> Vector2:
	if life_bar.x > max_life:
		life_bar.x = max_life
	elif life_bar.x < min_life:
		life_bar.x = min_life
	
	return life_bar

func change_life(life: float):
	if is_invincible == true:
		return 0
		
	is_invincible = true
	
	var signal_name = 'life_reduced' if life < 0 else 'life_increased'

	var timer: Timer = get_node('InvincibilitySpan')
	timer.start(invincibility_span)
		
	var life_bar_end_point: Vector2 = get_point_position(1)
	
	var changed: Vector2 = change_life_bar_size(life_bar_end_point, life)
	var life_bar_new_end_point: Vector2 = set_defaults(changed)
	
	if tween == null:
		tween = create_tween()
		tween.set_trans(Tween.TRANS_ELASTIC)
	
	tween.tween_method(func (vector: Vector2): set_point_position(1, vector), life_bar_end_point, life_bar_new_end_point, invincibility_span)
	
	if life_bar_new_end_point.x == 0:
		emit_signal('life_depleted')
	else:
		emit_signal(signal_name, life)
	
	return life_bar_new_end_point.x

func _on_invincibility_span_timeout():
	tween = null
	is_invincible = false
