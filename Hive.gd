extends Spatial

onready var Bee = preload("res://Bee.tscn")

onready var nectar_amount = 0

func add_payload(amount):
	nectar_amount += amount
	print(nectar_amount)

func _ready():
	for i in range(100):
		var bee = Bee.instance()
		add_child(bee)
		bee.hive = self
