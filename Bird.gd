extends KinematicBody
class_name Bird
func get_class(): return "Bird"

const MAX_SPEED = 1

var velocity
onready var speed = 15

func on_timeout():
	rotate(Vector3.UP, deg2rad(rand_range(-5, 5)))
	rotate(Vector3.FORWARD, deg2rad(rand_range(-5, 5)))
	$Timer.start(rand_range(5, 25))

func cohere(com, N):
	com /= N - 1
	var target = (com - global_transform.origin) / 100
	look_at(target, Vector3.UP)
	return target

func separate(boid):
	var sep = Vector3.ZERO
	if boid.global_transform.origin.distance_to(global_transform.origin) < 5:
		sep = -(global_transform.origin.direction_to(boid.global_transform.origin))
		look_at(sep, Vector3.UP)
	return sep

func align(boid):
	var p = Vector3.ZERO
	p += boid.velocity
	p /= get_parent().get_child_count()
	return (p - velocity) / 8

func apply_rules():
	var cohesion = Vector3.ZERO
	var alignment = Vector3.ZERO
	var collision = Vector3.ZERO
	var separation = Vector3.ZERO

	for boid in $Area.get_overlapping_bodies():
		alignment += boid.velocity
		cohesion += boid.global_transform.origin
		separation = boid.global_transform.origin - global_transform.origin
		if boid.global_transform.origin.distance_to(global_transform.origin) < 15:
			collision -= separation / boid.global_transform.origin.distance_to(global_transform.origin)

	return alignment + (cohesion / len($Area.get_overlapping_bodies())) + collision

func _process(delta):
	velocity = Vector3.ZERO
#	print_debug(velocity)
	var com = Vector3.ZERO
	velocity += apply_rules()
	velocity += -transform.basis.z * speed
	if velocity.z >= MAX_SPEED:
		velocity.z = 0
	move_and_slide(velocity)

func _ready():
	velocity = Vector3.ZERO
#	$Timer.connect("timeout", self, "on_timeout")
#	$Timer.start(5)
