class_name LevelUI extends CanvasLayer
const ColorRYB = preload("res://Assets/Scripts/ColorRYB.gd").ColorRYB

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await $"..".ready
	get_node("TopPanel").mouse_entered.connect(func(): LevelManager.this.GridM.resetHighlight())
	get_node("PauseButton").mouse_entered.connect(func(): LevelManager.this.GridM.resetHighlight())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if not LevelManager.this.WaveM.WaveDelayTimer.is_stopped():
		startWaveLabel.text = str(LevelManager.this.WaveM.WaveDelayTimer.time_left+1).pad_decimals(0) 

@onready var camera: Camera3D = get_viewport().get_camera_3d()

@onready var towerRotationPanel: Panel = $TowerRotationPanel
@onready var rotateClockwiseButton: Button = $TowerRotationPanel/RotateClockwiseButton
@onready var rotateCounterClockwiseButton: Button = $TowerRotationPanel/RotateCounterClockwiseButton

@onready var towerConfigurationPanel: Panel = $TowerConfigurationPanel
@onready var upgradeButton: Button = $TowerConfigurationPanel/UpgradeButton
@onready var destroyButton: Button = $TowerConfigurationPanel/DestroyButton
@onready var towerConfigurationMenus = {
	"Emitter": $TowerConfigurationPanel/Emitter,
	"Mirror": $TowerConfigurationPanel/Mirror,
	"Filter": $TowerConfigurationPanel/Filter,
	"Lens": $TowerConfigurationPanel/Lens,
	"Prism": $TowerConfigurationPanel/Prism
}
@onready var emitterIntensityLabel: Label = $TowerConfigurationPanel/Emitter/IntensityValueLabel
@onready var emitterDistanceLabel: Label = $TowerConfigurationPanel/Emitter/DistanceValueLabel
@onready var emitterColorDropDown: OptionButton = $TowerConfigurationPanel/Emitter/ColorDropDown
@onready var mirrorIntensityPenaltyLabel: Label = $TowerConfigurationPanel/Mirror/IntensityPenaltyValueLabel
@onready var filterIntensityPenaltyLabel: Label = $TowerConfigurationPanel/Filter/IntensityPenaltyValueLabel
@onready var filterColorDropDown: OptionButton = $TowerConfigurationPanel/Filter/ColorDropDown
@onready var lensIntensityPenaltyLabel: Label = $TowerConfigurationPanel/Lens/IntensityPenaltyValueLabel
@onready var lensCoefficientSlider: Slider = $TowerConfigurationPanel/Lens/CoefficientSlider
@onready var prismIntensityPenaltyLabel: Label = $TowerConfigurationPanel/Prism/IntensityPenaltyValueLabel

@onready var towerPlacementPanel = $TowerPlacementPanel

@onready var currencyLabel: Label = $TopPanel/Currency/Label
@onready var healthLabel: Label = $TopPanel/Health/Label

@onready var pauseMenu = $PauseMenu
@onready var missionWin = $MissionWin
@onready var missionLose = $MissionLose

@onready var startWaveButton = $TopPanel/StartWave
@onready var startWaveLabel = $TopPanel/StartWave/Label
@onready var startWaveHoldTimer = $TopPanel/StartWave/StartWaveHoldTimer
@onready var waveLabel = $TopPanel/StartWave/HBoxContainer/WaveLabel
@onready var maxWaveLabel = $TopPanel/StartWave/HBoxContainer/MaxWaveLabel

#__________ Tower Configuration __________

func resetTowerPanel():
	towerConfigurationPanel.global_position = Vector2(0, 720)
	towerRotationPanel.global_position = Vector2(0, 720)
	for menu in towerConfigurationMenus.values(): menu.visible = false

func showTowerConfigurationPanel(tower):
	towerConfigurationPanel.global_position = Vector2(1030, 0)
	towerRotationPanel.global_position = camera.unproject_position(LevelManager.this.GridM.map_to_local(tower.cellCoords[0])) + Vector2(-towerRotationPanel.size.x / 2, towerRotationPanel.size.y / 2)
	
	rotateClockwiseButton.disabled = !tower.rotatable
	rotateCounterClockwiseButton.disabled = !tower.rotatable
	upgradeButton.disabled = !tower.upgradable
	destroyButton.disabled = !tower.destroyable

	towerConfigurationMenus[tower.getTowerKey()].visible = true
	match (tower.getTowerKey()):
		"Emitter":
			tower = (tower as Emitter)
			emitterIntensityLabel.text = "%.0f" % tower.intensity
			emitterDistanceLabel.text = "%.0f" % tower.distance
			emitterColorDropDown.clear()
			for i in range(7):
				if tower.availableColors.has((i as ColorRYB)):
					emitterColorDropDown.add_item(ColorRYB.keys()[i as ColorRYB], i)
			emitterColorDropDown.selected = emitterColorDropDown.get_item_index(tower.color)
		"Mirror":
			mirrorIntensityPenaltyLabel.text = "%.0f" % ((tower as Mirror).intensity_penalty * 100) + "%"
		"Filter":
			tower = (tower as Filter)
			filterIntensityPenaltyLabel.text = "%.0f" % (tower.intensity_penalty * 100) + "%"
			filterColorDropDown.clear()
			for i in range(7):
				if tower.availableColors.has((i as ColorRYB)):
					filterColorDropDown.add_item(ColorRYB.keys()[i as ColorRYB], i)
			filterColorDropDown.selected = filterColorDropDown.get_item_index(tower.color)
		"Lens":
			tower = (tower as Lens)
			lensIntensityPenaltyLabel.text = "%.0f" % (tower.intensity_penalty * 100) + "%"
			lensCoefficientSlider.value = tower.modification_coefficient
		"Prism":
			prismIntensityPenaltyLabel.text = "%.0f" % ((tower as Prism).intensity_penalty * 100) + "%"


func _on_rotate_clockwise_button_pressed() -> void:
	LevelManager.this.GridM.configuratedTower.rotateTower(true)

func _on_rotate_counter_clockwise_button_pressed() -> void:
	LevelManager.this.GridM.configuratedTower.rotateTower(false)

func _on_configure_button_pressed() -> void:
	LevelManager.this.GridM.configuratedTower.configureTower()

func _on_destroy_button_pressed() -> void:
	LevelManager.this.GridM.set_cell_item(LevelManager.this.GridM.configuratedTower.cellCoords[0], LevelManager.this.GridM.mesh_library.find_item_by_name("TowerTile"))
	for pos in LevelManager.this.GridM.configuratedTower.cellCoords:
		LevelManager.this.GridM.towers.erase(pos)
	LevelManager.this.GridM.configuratedTower.destroyTower()
	
	LevelManager.this.GridM.state = LevelManager.this.GridM.State.None
	resetTowerPanel()

func _on_emitter_color_dropdown_item_selected(index: int) -> void:
	(LevelManager.this.GridM.configuratedTower as Emitter).color = emitterColorDropDown.get_item_id(index) as ColorRYB

func _on_filter_color_dropdown_item_selected(index: int) -> void:
	(LevelManager.this.GridM.configuratedTower as Filter).color = filterColorDropDown.get_item_id(index) as ColorRYB

func _on_lens_coefficient_slider_value_changed(value: float) -> void:
	(LevelManager.this.GridM.configuratedTower as Lens).modification_coefficient = value

#__________ Tower Placement __________

func showTowerPlacementPanel():
	towerPlacementPanel.position.x = 1030.0

func hideTowerPlacementPanel():
	towerPlacementPanel.position.x = 1030.0 + 250.0

func _on_place_tower_button_pressed(button: Button) -> void:
	var gridmap = LevelManager.this.GridM
	
	gridmap.placeTower(button.get_meta("TowerType"), gridmap.active_cell_coords)
	gridmap.resetHighlight()
	gridmap.state = gridmap.State.None
	hideTowerPlacementPanel()
	
	#if gridmap.state == gridmap.State.None:
		#gridmap.state = gridmap.State.Placing
		#gridmap.placingTowerKey = button.get_meta("TowerType")
	#elif gridmap.state == gridmap.State.Placing:
		#gridmap.state = gridmap.State.None
		#gridmap.resetHighlight()

#__________ Pause Menu __________

func _on_continue_button_pressed() -> void:
	get_tree().paused = false
	Engine.time_scale = 1.0
	pauseMenu.visible = false

func _on_options_button_pressed() -> void:
	SettingsManager.showSettingsMenu()

func _on_main_menu_button_pressed() -> void:
	get_tree().paused = false
	Engine.time_scale = 1.0
	get_tree().change_scene_to_file("res://Assets/Scenes/MainMenu.tscn")

func _on_pause_button_pressed() -> void:
	get_tree().paused = true
	pauseMenu.visible = true

#__________ Mission end screens __________

func show_mission_win():
	# TODO
	# Check if next level exists. If not? Block or delete NextLevelButton
	(get_node("MissionWin/Panel/HBoxContainer/NextLevelButton") as Button).disabled = true
	get_tree().paused = true
	missionWin.visible = true
	
func show_mission_lose():
	get_tree().paused = true
	missionLose.visible = true

#__________ Scene Manipulation __________

func _on_restart_button_pressed() -> void:
	get_tree().paused = false
	Engine.time_scale = 1.0
	get_tree().change_scene_to_file("res://Assets/Scenes/Level.tscn")

func _on_level_selection_button_pressed() -> void:
	get_tree().paused = false
	Engine.time_scale = 1.0
	get_tree().change_scene_to_file("res://Assets/Scenes/LevelSelectionMenu.tscn")

func _on_next_level_button_pressed() -> void:
	GlobalLevelManager.levelID += 1
	get_tree().paused = false
	Engine.time_scale = 1.0
	get_tree().change_scene_to_file("res://Assets/Scenes/Level.tscn")

#__________ Labels __________

func _update_hp() -> void:
	healthLabel.text = str(LevelManager.this.ResourceM.HP)

func _update_currency() -> void:
	currencyLabel.text = str(LevelManager.this.ResourceM.Resources)

#__________ Waves __________

func _on_start_wave_button_down() -> void:
	startWaveHoldTimer.timeout.connect(func():
		startWaveLabel.text = "auto"
		LevelManager.this.WaveM.autoLaunch = true
		LevelManager.this.WaveM.LaunchNextWave())
	startWaveHoldTimer.start(1)

func _on_start_wave_button_up() -> void:
	if not startWaveHoldTimer.is_stopped():
		startWaveHoldTimer.stop()
		startWaveLabel.text = ""
		LevelManager.this.WaveM.autoLaunch = false
		LevelManager.this.WaveM.LaunchNextWave()
		LevelManager.this.WaveM.WaveDelayTimer.stop()

func _on_fast_forward_toggled(toggled_on: bool) -> void:
	if toggled_on:
		Engine.time_scale = 2.0
	else:
		Engine.time_scale = 1.0
