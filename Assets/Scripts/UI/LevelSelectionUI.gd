extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_back_to_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Assets/Scenes/MainMenu.tscn")



func _on_level_button_pressed(button) -> void:
	GlobalLevelManager.levelID = (button as Button).text.to_int()
	get_tree().change_scene_to_file("res://Assets/Scenes/TestLevel.tscn")


func _on_test_level_button_pressed() -> void:
	GlobalLevelManager.levelID = -1
	get_tree().change_scene_to_file("res://Assets/Scenes/TestLevel.tscn")
