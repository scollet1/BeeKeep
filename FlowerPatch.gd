extends Area
class_name FlowerPatch
func get_class(): return "FlowerPatch"

onready var Flower = preload("res://Flower.tscn")

onready var score = 50

func get_nearest_flower(position):
	var flowers = get_children()
	var closest = get_child(1)
	flowers.erase(get_node("CollisionShape"))
	for i in flowers:
		if i.global_transform.origin.distance_to(position) < closest.global_transform.origin.distance_to(position):
			closest = i
	return closest

func get_random_flower(position):
	var flowers = get_children()
	flowers.erase(get_node("CollisionShape"))
	return flowers[randi() % len(flowers)]

func _ready():
	var num_flowers = randi() % 50
	for i in range(num_flowers):
		var flower = Flower.instance()
		flower.translation = Vector3(
			rand_range(-5, 5),
			0,
			rand_range(-5, 5)
		)
		flower.rotate_y(deg2rad(rand_range(0, 360)))
		add_child(flower)
	score = num_flowers * 10
