class_name DriftZone
extends Area2D

@export var points_stars2 := 200
@export var points_stars3 := 300
@export var reputation := 50

@export var hide_line := true

var _was_wrong_entered := false

var _is_completed = false

var _is_active := false
var _direction := 0
var _current_point := 0
var _player: Node2D

var _points_global: Array[Vector2] = []
var _points_count := 0
var _line_width_squared := 0.0

var _max_dist_from_line_squared := 0.0
var _max_return_dist := 0.0
var _max_segment_dist := 0.0
var _max_segment_progress := 0.0
var _min_dist_next := 999999.0
var _line_pos := Vector2.ZERO


func _ready():
	if hide_line:
		$Line2D.visible = false
	for point in $Line2D.points:
		_points_global.append($Line2D.to_global(point))
	
	_points_count = _points_global.size()
	_line_width_squared = pow($Line2D.width, 2)
	_max_return_dist = $Line2D.width * 0.6
	_max_dist_from_line_squared = _line_width_squared
	
	await get_tree().process_frame
	var collision_polygon := create_collision_polygon_from_line($Line2D)
	add_child(collision_polygon)


func _process(delta):
	if _is_active == false:
		return
		
	var next_point := _current_point + _direction
	var player_pos := _player.global_position
	
	# Check if we are still close enough to current segment
	var pos1 := _points_global[_current_point]
	var pos2 := _points_global[next_point]
	_line_pos = _find_line_pos(player_pos, pos1, pos2)

	# Progress on line
	var segment_dist := _line_pos.distance_to(pos1)
	if segment_dist > _max_segment_dist:
		_max_segment_dist = segment_dist
		_max_segment_progress = pos1.distance_to(_line_pos) / pos1.distance_to(pos2)
		
	var next_dist := player_pos.distance_to(pos2)
	if next_dist < _min_dist_next:
		_min_dist_next = next_dist
	
	# Check if we have returned back too far
	if next_dist - _min_dist_next > _max_return_dist:
		print("went back too far: ", _max_segment_dist - segment_dist, ", max=", _max_return_dist)
		EventBus.error_message.emit("Drift Zone Failed!\nWrong direction")
		_end_drift_zone(false)
		return
	
	# Check if we have reached the next point
	var dist = player_pos.distance_squared_to(_points_global[next_point])
	if dist < _line_width_squared:
		if next_point + _direction >= 0 and next_point + _direction <= _points_count - 1:
			_current_point += _direction
			_max_segment_dist = 0.0
			_max_segment_progress = 0.0
			_min_dist_next = 999999.0
			print("DriftZone progressed, _current_point=", _current_point)


func _find_nearest_point(pos: Vector2) -> int:
	var min_dist_squared = 0.0
	var nearest_point = -1
	for i in range(_points_count):
		var dist = pos.distance_squared_to(_points_global[i])
		if dist < min_dist_squared or nearest_point == -1:
			nearest_point = i
			min_dist_squared = dist
	
	return nearest_point


func get_stars(points: int) -> int:
	if points >= points_stars3:
		return 3
	elif points >= points_stars2:
		return 2
	else:
		return 1


func _end_drift_zone(is_completed: bool):
	if not _is_active:
		return
		
	_is_active = false
	
	EventBus.player_exit_drift_zone.emit(_player, self, is_completed, _player.get_node("DriftPoints").get_total_drift_zone_points())
	print("DriftZone stopped, is_completed=", is_completed)


func _find_line_pos(pos: Vector2, a: Vector2, b: Vector2) -> Vector2:
	var ab = b - a
	var ap = pos - a
	var ab_length_squared = ab.length_squared()
	if ab_length_squared == 0:
		return a
	var t = ap.dot(ab) / ab_length_squared
	t = clamp(t, 0.0, 1.0)
	return a + t * ab


func _on_body_entered(body: Node2D):
	if _is_active:
		return
	if body.is_in_group("player") == false:
		return
	
	# Find point on line nearest to player
	var nearest_index = _find_nearest_point(body.global_position)
	if nearest_index != 0 and nearest_index != _points_count - 1:
		print("DriftZone entered from wrong side")
		if _was_wrong_entered == false:
			_was_wrong_entered = true
			EventBus.error_message.emit("Enter drift zone from start or end")
		return
		
	# Determine whether we are on start or end of the line
	# and direction in which we are going to complete the drift zone
	var end_index = _points_count - 1
	if abs(end_index - nearest_index) > abs(0 - nearest_index):
		_direction = 1
		_current_point = 0
	else:
		_direction = -1
		_current_point = end_index
	
	_max_segment_dist = 0.0
	_max_segment_progress = 0.0
	_min_dist_next = 999999.0
	_player = body
	_is_active = true
	EventBus.player_enter_drift_zone.emit(_player, self)
	print("DriftZone started: _direction=", _direction, ", _current_point=", _current_point)


func _on_body_exited(body):
	if _is_active == false or body != _player:
		return
		
	var is_last_point = _current_point <= 1 or _current_point >= _points_count - 2
	var is_completed = is_last_point and _max_segment_progress > 0.95
	_end_drift_zone(is_completed)
	
	if not is_completed:
		EventBus.error_message.emit("Drift Zone Failed!\nToo far from the road")
	
	if is_completed and not _is_completed:
		get_tree().get_first_node_in_group("game_manager").add_reputation(reputation)
		_is_completed = true
	

func create_collision_polygon_from_line(line: Line2D) -> CollisionPolygon2D:
	var collision_polygon = CollisionPolygon2D.new()
	var polygon_points = []

	var half_width = line.width / 2
	var points = line.points

	var top_points = []
	var bottom_points = []

	for i in range(points.size()):
		var current_point = points[i]
		
		var previous_dir = Vector2.ZERO
		var next_dir = Vector2.ZERO
		
		if i > 0:
			previous_dir = (points[i] - points[i - 1]).normalized()
		if i < points.size() - 1:
			next_dir = (points[i + 1] - points[i]).normalized()
		
		var average_normal = Vector2.ZERO
		var angle_factor = 1.0

		if previous_dir != Vector2.ZERO and next_dir != Vector2.ZERO:
			var previous_perpendicular = Vector2(-previous_dir.y, previous_dir.x)
			var next_perpendicular = Vector2(-next_dir.y, next_dir.x)
			average_normal = (previous_perpendicular + next_perpendicular).normalized()

			var angle_cos = previous_dir.dot(next_dir)
			if angle_cos < 1.0:
				angle_factor = 1.0 / cos(acos(angle_cos) / 2.0)
		elif previous_dir != Vector2.ZERO:
			average_normal = Vector2(-previous_dir.y, previous_dir.x)
		elif next_dir != Vector2.ZERO:
			average_normal = Vector2(-next_dir.y, next_dir.x)

		var offset1 = average_normal * half_width * angle_factor
		var offset2 = -average_normal * half_width * angle_factor
		
		top_points.append(current_point + offset1)
		bottom_points.append(current_point + offset2)

	polygon_points.append_array(top_points)
	bottom_points.reverse()
	polygon_points.append_array(bottom_points)

	collision_polygon.polygon = polygon_points
	collision_polygon.position = line.position
	return collision_polygon
