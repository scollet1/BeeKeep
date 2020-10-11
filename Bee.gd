extends KinematicBody
class_name Bee
func get_class(): return "Bee"

onready var Flower = preload("res://Flower.tscn")

onready var speed = 5
onready var gravity = 0.5
onready var velocity = Vector3.ZERO

onready var payload = 0
onready var payload_capacity = 100

onready var hive = null
onready var flower_patch = null

enum {
	foraging = 1,
	resting = 2,
	harvesting = 3
}

var state = foraging

func payload_full():
	return payload >= payload_capacity

func compare_food_sources(source):
	if source and flower_patch:
		return source.score - flower_patch.score
	return 0

func recruit(bee):
	if bee:
		var score = bee.compare_food_sources(flower_patch)
		if score < 0:
			bee.flower_patch = flower_patch

func on_object_entered(object):
	if object.get_class() == "Bee" and object != self:
		recruit(object)

func set_flower(target):
	flower_patch = target

func detect_flower_patch():
	if $DetectFlower.is_colliding():
		var obj = $DetectFlower.get_collider()
		if obj.get_class() == "FlowerPatch":
			if flower_patch:
				if flower_patch.score <= obj.score:
					flower_patch = obj
			else:
				flower_patch = obj

func transition_state():
	match state:
		foraging:
			state = harvesting
			$Timer.start(35)
		resting:
			state = foraging
			$Timer.start(60)
		harvesting:
			state = resting
			$Timer.start(10)

func start_collecting(nearest_flower):
	var distance_to_nearest_flower = nearest_flower.global_transform.origin.distance_to(global_transform.origin)
	while distance_to_nearest_flower < 2 and !payload_full() and state == harvesting:
		payload += 1
		yield(get_tree().create_timer(0.1), "timeout")

func harvest_flower(nearest_flower):
	var distance_to_nearest_flower = nearest_flower.global_transform.origin.distance_to(global_transform.origin)
	velocity.z = distance_to_nearest_flower * randf()
	rotation.y = 0
	if state == foraging:
		transition_state()
		var thread = Thread.new()
		thread.start(self, "start_collecting", nearest_flower)
		thread.wait_to_finish()

func track_to_flower(nearest_flower):
	var distance_to_nearest_flower = nearest_flower.global_transform.origin.distance_to(global_transform.origin)
	velocity = -nearest_flower.global_transform.origin.direction_to(global_transform.origin)
	if distance_to_nearest_flower <= 2 and state != harvesting:
		harvest_flower(nearest_flower)

func forage():
	var nearest_flower = flower_patch.get_nearest_flower(global_transform.origin).bulb
	if state == foraging:
		nearest_flower = flower_patch.get_random_flower(global_transform.origin).bulb
	look_at(lerp(global_transform.origin, nearest_flower.global_transform.origin, 0.3), Vector3.UP)
	var distance_to_nearest_flower = nearest_flower.global_transform.origin.distance_to(global_transform.origin)
	if distance_to_nearest_flower < 15 and state != resting:
		track_to_flower(nearest_flower)

func _physics_process(delta):
	var last_velocity = velocity
	velocity.y = rand_range(-100, 100)
	if translation.y <= 0.5:
		velocity.y = 25
	elif translation.y >= 15:
		velocity.y = -50
	velocity.z = rand_range(-50, 50)
	velocity.x = rand_range(-50, 50)
	detect_flower_patch()
#	prints(flower_patch, payload_full(), state)
	if flower_patch and !payload_full() and state != resting:
		forage()
	elif state == resting or payload_full() or hive.global_transform.origin.distance_to(global_transform.origin) >= 20:
		look_at(lerp(translation, hive.global_transform.origin, 0.3), Vector3.UP)
		if hive.global_transform.origin.distance_to(global_transform.origin) <= 1:
			hive.add_payload(payload)
			payload = 0
			velocity.z = -hive.global_transform.origin.distance_to(global_transform.origin)
	rotation.x = 0
	velocity += -transform.basis.z * speed
	velocity = lerp(last_velocity, velocity, 0.02)
	if velocity < Vector3(1, 1, 1):
		$AnimationPlayer.stop(true)
	else:
		$AnimationPlayer.play("Flying")
	velocity = move_and_slide(velocity, Vector3.UP)

func _ready():
	$Timer.connect("timeout", self, "transition_state")
	$Area.connect("body_entered", self, "on_object_entered")
	$Timer.one_shot = true
	$Timer.start(5)
