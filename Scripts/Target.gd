extends RefCounted
class_name Target

var can_stop_laser: bool


func Can_stop_laser() -> bool:
	return can_stop_laser


func Got_hit_by_laser(laser: Node) -> void:
	pass
	

func While_hit_by_laser(laser: Node) -> void:
	print("HIT by laser: ", laser.name)
