extends KinematicBody
class_name Firefly
func get_class(): return "Firefly"

onready var decay = 10

onready var speed = 5
onready var gravity = 0.5
onready var velocity = Vector3.ZERO

func on_timeout():
	$OmniLight.light_energy = 16
	$Timer.start(5)

func on_body_entered(body):
	if body.get_class() == "Firefly" and body != self:
		$Timer.start($Timer.time_left - 0.5)
		look_at(lerp(global_transform.origin, body.global_transform.origin, 0.01), Vector3.UP)
		velocity += body.velocity

func _process(delta):
	if $OmniLight.light_energy > 0:
		$OmniLight.light_energy -= decay * delta
	else:
		$OmniLight.light_energy = 0

	var last_velocity = velocity
	velocity.y = rand_range(-100, 100)
	if translation.y <= 0.5:
		velocity.y = 10
	elif translation.y >= 15:
		velocity.y = -10
	velocity.z = rand_range(-50, 50)
	velocity.x = rand_range(-50, 50)
	rotation.x = 0
	velocity += -transform.basis.z * speed
	velocity = lerp(translation.direction_to(Vector3.ZERO), lerp(last_velocity, velocity, 0.02), 0.9)
	velocity = move_and_slide(velocity, Vector3.UP)

func _ready():
	$Timer.one_shot = false
	$Timer.autostart = true
	$Timer.connect("timeout", self, "on_timeout")
	$Timer.start(5)
	$Area.connect("body_entered", self, "on_body_entered")
