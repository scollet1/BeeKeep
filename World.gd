extends Spatial

onready var Firefly = preload("res://Firefly.tscn")

func _ready():
	for i in range(10):
		var firefly = Firefly.instance()
		firefly.translation = Vector3(rand_range(-20, 20), rand_range(-20, 20), rand_range(-20, 20))
		add_child(firefly)
