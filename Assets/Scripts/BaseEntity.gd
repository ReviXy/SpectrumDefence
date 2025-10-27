extends PathFollow3D
class_name BaseEntity

@export var BaseSpeed: float = 3
@export var SpeedMult: float = 1
@export var EnemyColor: Color = Color(128,128,128,255)
@export var HP: float = 100
@export var Damage: int = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	LevelMaster.this.EntityCount += 1
	
func _exit_tree() -> void:
	LevelMaster.this.EntityCount -= 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	if (HP <= 0):
		queue_free()
		return
	progress += BaseSpeed*SpeedMult*delta
	if progress_ratio == 1:
		LevelMaster.this.ReachedExit(self)
		queue_free()
