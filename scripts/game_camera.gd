class_name GameCamera
extends Camera2D

var target: Node2D = null

var _limit_top_left = Vector2.ZERO
var _limit_bottom_right = Vector2.ZERO
var _is_limits_initialized = false

var _transition_running = false
var _transition_progress = 0.0
var _transition_duration = 0.0
var _transition_start_position = Vector2.ZERO
var _transition_target_position = Vector2.ZERO


func _ready():
	if not target:
		target = get_tree().get_first_node_in_group("player")

func get_camera_rect() -> Rect2:
	var pos = position # Camera's center
	var half_size = get_viewport_rect().size * 0.5
	return Rect2(pos - half_size, pos + half_size)


func get_pos_within_limits(target_pos: Vector2, top_left: Vector2, bottom_right: Vector2) -> Vector2:
	var camera_position = target_pos
	
	var camera_zoom = zoom
	var viewport_size = get_viewport().get_visible_rect().size
	var half_world_size = (viewport_size / 2) / camera_zoom
	
	var min_camera_x = top_left.x + half_world_size.x
	var max_camera_x = bottom_right.x - half_world_size.x
	var min_camera_y = top_left.y + half_world_size.y
	var max_camera_y = bottom_right.y - half_world_size.y
	
	camera_position.x = clamp(camera_position.x, min_camera_x, max_camera_x)
	camera_position.y = clamp(camera_position.y, min_camera_y, max_camera_y)
	
	return camera_position


func do_transition(target_pos: Vector2, duration: float):
	_transition_progress = 0.0
	_transition_duration = duration
	_transition_running = true
	_transition_start_position = global_position
	_transition_target_position = target_pos


func _process(delta):
	if _transition_running:
		_transition_progress += min(1.0, delta / _transition_duration)
		
		var t = 0.0
		var start_at = 0.1 / _transition_duration
		if _transition_progress > start_at:
			t = (_transition_progress - start_at) / (1.0 - start_at)
		
		global_position = _transition_start_position.lerp(_transition_target_position, t)
		
		if _transition_progress >= 1.0:
			_transition_running = false
			get_tree().paused = false
	else:
		if target:
			var target_pos = target.global_position
			global_position = get_pos_within_limits(target_pos, _limit_top_left, _limit_bottom_right)
	


func transition_to_level_area(area: LevelArea):
	var shape = area.get_child(0) as CollisionShape2D
	if not shape:
		return
		
	var rect = shape.shape.get_rect()
	var top_left = shape.to_global(rect.position)
	var bottom_right = shape.to_global(rect.position + rect.size)
	
	_limit_top_left = top_left
	_limit_bottom_right = bottom_right	
	if _is_limits_initialized:
		var new_position = get_pos_within_limits(global_position, top_left, bottom_right)
		get_tree().paused = true
		do_transition(new_position, 0.75)
	else:
		reset_smoothing()
		_limit_top_left = top_left
		_limit_bottom_right = bottom_right
		_is_limits_initialized = true
