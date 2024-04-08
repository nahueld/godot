extends Node

var player

# Called when the node enters the scene tree for the first time.
func _ready():
	player = find_parent("*")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	print(player.velocity.x)
	pass
