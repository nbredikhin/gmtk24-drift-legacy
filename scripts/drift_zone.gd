extends Area2D

var _is_active = false
var _direction = 0
var _next_point = 0
var _player: Node2D

func _ready():
	pass # Replace with function body.


func _process(delta):
	if _is_active == false:
		return
		
	var dist = _player.global_position.distance_to($Line2D.to_global($Line2D.points[_next_point]))
	if dist < $Line2D.width:
		if _next_point + _direction >= 0 and _next_point + _direction <= $Line2D.get_point_count() - 1:
			_next_point += _direction
			print("DriftZone progressed, next_point=", _next_point)


func _find_nearest_point(pos: Vector2) -> int:
	var min_dist_squared = 0.0
	var nearest_point = -1
	for i in range($Line2D.get_point_count()):
		var point_pos = $Line2D.to_global($Line2D.points[i])
		var dist = pos.distance_squared_to(point_pos)
		if dist < min_dist_squared or nearest_point == -1:
			nearest_point = i
			min_dist_squared = dist
	
	return nearest_point


func _set_active(state: bool, is_failed = false):
	if _is_active == state:
		return
		
	_is_active = state
	
	if _is_active:
		# Find point on line nearest to player
		var nearest_index = _find_nearest_point(_player.global_position)
		# Determine whether we are on start or end of the line
		# and direction in which we are going to complete the drift zone
		var end_index = $Line2D.get_point_count() - 1
		if abs(end_index - nearest_index) > abs(0 - nearest_index):
			_direction = 1
			_next_point = 1
		else:
			_direction = -1
			_next_point = end_index - 1
		
		print("DriftZone started: dir=", _direction, ", next=", _next_point)
	else:
		print("DriftZone stopped, is_failed=", is_failed)


func _on_body_entered(body: Node2D):
	if body.is_in_group("player") == false:
		return
	
	_player = body
	_set_active(not _is_active)	


func _on_body_exited(body):
	pass # Replace with function body.
