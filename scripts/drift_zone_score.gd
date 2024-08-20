extends Node2D

@export var target_zone: DriftZone


func _ready() -> void:	
	await get_tree().process_frame
	
	var min_dist = 0.0
	var nearest_zone = target_zone
	if not nearest_zone:
		for dz in get_tree().get_nodes_in_group("drift_zone"):
			var dist = dz.global_position.distance_to(global_position)
			if nearest_zone == null or dist < min_dist:
				nearest_zone = dz
				min_dist = dist
		target_zone = nearest_zone
	
	$Label1.text = "0 PTS"
	$Label2.text = str(nearest_zone.points_stars2," PTS")
	$Label3.text = str(nearest_zone.points_stars3," PTS")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
