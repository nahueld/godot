extends Node2D

@onready var projectile = $projectile
@onready var player = $player
@onready var life_bar = $player/LifeBar

var fly = preload("res://scenes/fly.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	player.connect('projectile_shot', on_projectile_shot)
	life_bar.connect('life_depleted', on_life_depleted)
	create_fly()
	create_fly()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func on_life_depleted():
	queue_free()

func on_projectile_shot(p):
	add_child(p)
	
func create_fly():
	var newFly = fly.instantiate()

	newFly.global_position = Vector2(
		(player.global_position.x + randf_range(-500,500)),
		(player.global_position.y + randf_range(-500,500))
	)
	
	add_child(newFly)

func _on_timer_timeout():
	create_fly()
