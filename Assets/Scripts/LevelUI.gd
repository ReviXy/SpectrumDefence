class_name LevelUI extends CanvasLayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await $"..".ready

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

@onready var camera = get_viewport().get_camera_3d()

@onready var towerConfigurationPanel = $TowerConfigurationPanel
@onready var rotateButton = $TowerConfigurationPanel/RotateButton
@onready var configureButton = $TowerConfigurationPanel/ConfigureButton
@onready var destroyButton = $TowerConfigurationPanel/DestroyButton

@onready var towerPlacementPanel = $TowerPlacementPanel
@onready var minimizePanelButton = $TowerPlacementPanel/MinimizePanelButton
var minimized := false

@onready var currencyLabel = $Currency/Label
@onready var healthLabel = $Health/Label
# soon to be manager (get promoted upon merge)

func resetTowerPanel():
	towerConfigurationPanel.global_position = Vector2(-50, -50)

func showTowerPanel(tower):
	towerConfigurationPanel.global_position = camera.unproject_position(LevelManager.this.GridM.map_to_local(tower.cellCoords[0]))
	rotateButton.disabled = !tower.rotatable
	configureButton.disabled = !tower.configurable
	destroyButton.disabled = !tower.destroyable

func _on_rotate_button_pressed() -> void:
	LevelManager.this.GridM.configuratedTower.rotateTower()

func _on_configure_button_pressed() -> void:
	pass 

func _on_destroy_button_pressed() -> void:
	LevelManager.this.GridM.set_cell_item(LevelManager.this.GridM.configuratedTower.cellCoords[0], LevelManager.this.GridM.mesh_library.find_item_by_name("TowerTile"))
	for pos in LevelManager.this.GridM.configuratedTower.cellCoords:
		LevelManager.this.GridM.towers.erase(pos)
	LevelManager.this.GridM.configuratedTower.destroyTower()
	
	LevelManager.this.GridM.state = LevelManager.this.GridM.State.None
	resetTowerPanel()

func _on_minimize_panel_button_pressed() -> void:
	if minimized:
		towerPlacementPanel.global_position.x -= 250
		minimizePanelButton.text = "->"
	else: 
		towerPlacementPanel.global_position.x += 250
		minimizePanelButton.text = "<-"
	minimized = !minimized

func _on_place_test_tower_button_pressed() -> void:
	if LevelManager.this.GridM.state == LevelManager.this.GridM.State.None: 
		LevelManager.this.GridM.state = LevelManager.this.GridM.State.Placing
	elif LevelManager.this.GridM.state == LevelManager.this.GridM.State.Placing: 
		LevelManager.this.GridM.state = LevelManager.this.GridM.State.None
		LevelManager.this.GridM.resetHighlight()

func _update_hp() -> void:
	healthLabel.text = str(LevelManager.this.ResourceM.HP)

func _update_currency() -> void:
	currencyLabel.text = str(LevelManager.this.ResourceM.AbsractTowerCurrency)
