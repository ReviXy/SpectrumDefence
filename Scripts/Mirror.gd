extends Node3D  # или любой другой Node

func _ready():
	print("Создано зеркало")
	add_to_group("Mirror")
	print("Группы после добавления: ", get_groups())
