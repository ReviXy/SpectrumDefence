class_name Tower extends Node3D

var cellCoords = []

var active = true
var rotatable = true
var configurable = true
var destroyable = true

# functions for rotate, destroy, configure placeholder

func rotateTower():
	self.rotation_degrees.y = int(self.rotation_degrees.y + 45) % 360
	
func destroyTower():
	self.queue_free()
	
func configureTower():
	#placeholder
	pass
