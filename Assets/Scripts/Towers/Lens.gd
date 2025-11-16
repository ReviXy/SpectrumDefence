class_name Lens extends BaseTower

@onready var laser_prefab = preload("res://Assets/Scenes/Towers/Laser.tscn")

@export_range(0.1, 2.0, 0.01) var modification_coefficient: float = 0.5:
	set(new_modification_coefficient):
		if (new_modification_coefficient > 2):
			modification_coefficient = 2
		elif (new_modification_coefficient < 0.1):
			modification_coefficient = 0.1
		else: 
			modification_coefficient = new_modification_coefficient

var intensity_penalty: float = 0.1
var laser_dictionary = {}

func configureTower():
	pass

func begin_laser_collision(laser: Laser):
	var new_laser: Laser = laser_prefab.instantiate()
	add_child(new_laser)
	laser_dictionary[laser] = new_laser
	continue_laser_collision(laser)

func continue_laser_collision(laser):
	var laser_direction = (laser.get_collision_point() - laser.global_position).normalized()
	laser_dictionary[laser].position = to_local(laser.get_collision_point())
	laser_dictionary[laser].look_at(laser_dictionary[laser].global_position + laser_direction, Vector3.UP)
	laser_dictionary[laser].rotate_object_local(Vector3.RIGHT, -PI / 2)
	
	laser_dictionary[laser].color = laser.color
	laser_dictionary[laser].distance = (laser.distance - laser.global_position.distance_to(laser.get_collision_point())) * modification_coefficient
	laser_dictionary[laser].intensity = laser.intensity * (1 - intensity_penalty) * (1 / modification_coefficient)

func end_laser_collision(laser):
	laser_dictionary[laser].queue_free()
	laser_dictionary.erase(laser)
