extends KinematicBody

var speed = 10
var acceleration = 20
var gravity = 15.0
var jump = 5

var mouse_sensitivity = 0.5

var direction = Vector3()
var velocity = Vector3()
var fall = Vector3()

onready var head = get_node("Head")

func intersect_object():
	var head = $Head
	var camera = head.get_node("Camera")
	var to = camera.project_ray_origin(OS.get_screen_size() * 0.5)
	var from = to + camera.project_ray_normal(OS.get_screen_size() * 0.5) * 100
	var space_state = get_world().direct_space_state
	var result = space_state.intersect_ray(to, from)
	if result: return result['collider']
	return null

func interact_with_entity():
	var object = intersect_object()
	if object:
		if object.get_class() == "Character":
			print_debug(object.get_class())
			object.interact()

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg2rad(-event.relative.x * mouse_sensitivity))
		head.rotate_x(deg2rad(-event.relative.y * mouse_sensitivity))
		head.rotation.x = clamp(head.rotation.x, deg2rad(-90), deg2rad(90))

func _process(delta):
	direction = Vector3()
#	if not is_on_floor():
#		fall.y -= gravity * delta
##	else:
#	if Input.is_action_pressed("move_jump"):
#		fall.y = jump
	if Input.is_action_pressed("move_back"):
		direction += transform.basis.z
	if Input.is_action_pressed("move_fowd"):
		direction -= transform.basis.z
	if Input.is_action_pressed("move_left"):
		direction -= transform.basis.x
	if Input.is_action_pressed("move_right"):
		direction += transform.basis.x
	if Input.is_action_just_pressed("interact"):
		interact_with_entity()
	direction = direction.normalized()
	velocity = velocity.linear_interpolate(direction * speed, acceleration * delta)
	velocity = move_and_slide(velocity, Vector3.UP, false)
	move_and_slide(fall, Vector3.UP, true)
