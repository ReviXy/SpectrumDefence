extends Camera3D

var move_speed = 20
var zoom_speed = 0.5  # Скорость зума
var size_min = 5      # Минимальный размер
var size_max = 50     # Максимальный размер

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	projection = Camera3D.PROJECTION_ORTHOGONAL

func _process(delta):
	var input_vector = Vector3.ZERO
	
	if Input.is_key_pressed(KEY_D):
		input_vector.x += 1
	if Input.is_key_pressed(KEY_A):
		input_vector.x -= 1
	if Input.is_key_pressed(KEY_S):
		input_vector.z += 1
	if Input.is_key_pressed(KEY_W):
		input_vector.z -= 1

	input_vector = input_vector.normalized().rotated(Vector3.UP,rotation.y)
	position += input_vector * move_speed * delta * size/30

func _input(event):
	if event is InputEventMouseButton:
		match event.button_index:
			MOUSE_BUTTON_WHEEL_UP:
				var size_change = size - clamp(size - zoom_speed, size_min, size_max)
				position += (Vector3.FORWARD * size_change).rotated(Vector3.RIGHT,rotation.x).rotated(Vector3.UP,rotation.y)
				size -= size_change
			MOUSE_BUTTON_WHEEL_DOWN:
				var size_change = clamp(size + zoom_speed, size_min, size_max) - size
				position -= (Vector3.FORWARD * size_change).rotated(Vector3.RIGHT,rotation.x).rotated(Vector3.UP,rotation.y)
				size += size_change
