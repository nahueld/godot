extends Node2D

@onready var projectile = $projectile
@onready var player = $player

var fly = preload("res://scenes/fly.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	player.connect('projectile_shot', on_projectile_shot)
	var lifeBar = player.get_node('LifeBar')
	
	if(lifeBar != null):
		lifeBar.connect('life_depleted', on_life_depleted)
	
	add_child(fly.instantiate())

func on_projectile_shot(p):
	add_child(p)

func on_life_depleted():
	print('life depleted event happened')
	queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_timer_timeout():
	var newFly = fly.instantiate()

	newFly.global_position = Vector2(
		(player.global_position.x + randf_range(-500,500)),
		(player.global_position.y + randf_range(-500,500))
	)
	
	add_child(newFly)
