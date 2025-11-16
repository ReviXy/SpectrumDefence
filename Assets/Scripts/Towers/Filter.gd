class_name Filter extends BaseTower
const ColorRYB = preload("res://Assets/Scripts/ColorRYB.gd").ColorRYB

@onready var laser_prefab = preload("res://Assets/Scenes/Towers/Laser.tscn")
@onready var indicator_material = ($Indicator).get_surface_override_material(0)

@export var color: ColorRYB = ColorRYB.Red:
	set(new_color):
		color = new_color
		indicator_material.albedo_color = ColorRYB_Operations.ToColor(new_color)
var intensity_penalty: float = 0.1
var laser_dictionary = {}

func _ready() -> void:
	rotatable = false

func configureTower():
	color = ((color + 1) % ColorRYB.size() ) as ColorRYB

func begin_laser_collision(laser: Laser):
	var filtered_color = ColorRYB_Operations.Filter(laser.color, color)
	if (filtered_color == null):
		return
	
	var new_laser: Laser = laser_prefab.instantiate()
	add_child(new_laser)
	var laser_direction = (laser.get_collision_point() - laser.global_position).normalized()
	new_laser.position = to_local(laser.get_collision_point())
	new_laser.look_at(new_laser.global_position + laser_direction, Vector3.UP)
	new_laser.rotate_object_local(Vector3.RIGHT, -PI / 2)
	
	new_laser.color = filtered_color
	new_laser.distance = laser.distance - laser.global_position.distance_to(laser.get_collision_point())
	new_laser.intensity = laser.intensity * (1 - intensity_penalty)
	laser_dictionary[laser] = new_laser

func continue_laser_collision(laser):
	var filtered_color = ColorRYB_Operations.Filter(laser.color, color)
	if (filtered_color == null):
		if (laser_dictionary.has(laser)):
			laser_dictionary[laser].queue_free()
			laser_dictionary.erase(laser)
		return
	
	if (!laser_dictionary.has(laser)):
		begin_laser_collision(laser)
	
	var laser_direction = (laser.get_collision_point() - laser.global_position).normalized()
	laser_dictionary[laser].position = to_local(laser.get_collision_point())
	laser_dictionary[laser].look_at(laser_dictionary[laser].global_position + laser_direction, Vector3.UP)
	laser_dictionary[laser].rotate_object_local(Vector3.RIGHT, -PI / 2)
	
	laser_dictionary[laser].color = filtered_color
	laser_dictionary[laser].distance = laser.distance - laser.global_position.distance_to(laser.get_collision_point())
	laser_dictionary[laser].intensity = laser.intensity * (1 - intensity_penalty)

func end_laser_collision(laser):
	if (laser_dictionary.has(laser)):
		laser_dictionary[laser].queue_free()
		laser_dictionary.erase(laser)
