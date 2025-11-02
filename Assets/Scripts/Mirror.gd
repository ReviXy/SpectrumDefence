class_name Mirror extends "res://Assets/Scripts/Target.gd"

func _ready():
	can_stop_laser = false

func Got_hit_by_laser(laser: Node) -> void:
	print("Got Hit")

func While_hit_by_laser(laser: Node) -> void:
	print("hit")
