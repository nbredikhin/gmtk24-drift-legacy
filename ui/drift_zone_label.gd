extends Control


func _ready() -> void:
	$DriftZoneCompletedLabel.visible = false
	$DriftZoneFailedLabel.visible = false
	$DriftZoneLabel.visible = false
	EventBus.player_enter_drift_zone.connect(_on_drift_zone_start)
	EventBus.player_drift_zone_points.connect(_on_drift_zone_points)
	EventBus.player_exit_drift_zone.connect(_on_drift_zone_end)


func _on_drift_zone_start(player: Car, zone: DriftZone):
	$DriftZoneLabel.visible = true
	$DriftZoneLabel.text = "DRIFT ZONE\n0"


func _on_drift_zone_points(player: Car, points: int):
	$DriftZoneLabel.text = str("DRIFT ZONE\n", Tools.thousands_sep(points))
	
	
func _on_drift_zone_end(player: Car, zone: DriftZone, is_completed: bool, points: int):
	$DriftZoneLabel.visible = false
	
	if is_completed:
		$DriftZoneCompletedLabel.visible = true
		$DriftZoneCompletedLabel/HideTimer.start()
		
		var stars_count = zone.get_stars(points)
		for i in range(1, 4):
			print(str("StarsFill",i))
			$DriftZoneCompletedLabel.get_node(str("StarFill",i)).visible = stars_count >= i


func _on_hide_timer_timeout() -> void:
	$DriftZoneCompletedLabel.visible = false
