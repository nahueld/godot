class_name Projectile extends RigidBody2D

var maxXSpeed = 100
var maxTorque = 1500
var xSpeed = self.maxXSpeed
var ySpeed = -500

func _ready():
	var cappedSpeed = get_capped_constant(self.xSpeed, self.maxXSpeed)
	self.apply_impulse(Vector2(cappedSpeed, ySpeed), Vector2.ZERO)
		
func _integrate_forces(state):
	var constantTorque = get_capped_constant(self.xSpeed, self.maxTorque)
	state.set_constant_torque(constantTorque)

func _process(delta):
	pass

# helpers
func get_capped_constant(value, cap):
	return -cap if value <= 0 else cap 

func _on_body_entered(body):
	if body is Fly:
		body.queue_free()
