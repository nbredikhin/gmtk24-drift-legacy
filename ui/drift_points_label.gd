extends Label


func _ready() -> void:
	visible = false
	EventBus.player_start_drift.connect(_on_drift_start)
	EventBus.player_drift_points.connect(_on_drift_points)
	EventBus.player_end_drift.connect(_on_drift_end)


func _on_drift_start(player: Car):
	visible = true
	

func _on_drift_points(player: Car, points: int):
	text = str("DRIFT\n",points)
	
	
func _on_drift_end(player: Car, is_completed: bool, points: int):
	visible = false
