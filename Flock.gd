extends Spatial

var center_of_mass

func calculate_center_of_mass():
	var com = Vector3()
	for i in get_children():
		com += i.global_transform.origin
	return com / (get_child_count())

func _process(delta):
	center_of_mass = calculate_center_of_mass()

func _ready():
	center_of_mass = calculate_center_of_mass()
