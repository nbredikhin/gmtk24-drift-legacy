extends Label


func _ready() -> void:
	visible = false
	EventBus.player_enter_drift_zone.connect(_on_drift_zone_start)
	EventBus.player_exit_drift_zone.connect(_on_drift_zone_end)


func _on_drift_zone_start(player: Car):
	visible = true
	
	
func _on_drift_zone_end(player: Car, is_completed: bool, points: int):
	visible = false
