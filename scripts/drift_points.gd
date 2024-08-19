extends Node

@export var time_to_complete_drift := 3.0
@export var min_drift_angle := 30.0
@export var max_drift_angle := 100.0
@export var min_drift_speed := 30.0
@export var max_drift_speed := 130.0

@export var points_for_angle := 200.0
@export var points_for_speed := 100.0
@export var points_switch_bonus := 500.0
@export var switch_bonus_side_time := 2.0
@export var switch_bonus_side_change_time := 0.8

@export var time_cooldown := 1.5

var points := 0.0
var drift_zone_points := 0.0
var is_drift_zone_active := false

var _drift_side := 0.0
var _cooldown := 0.0
var _last_drift_side := 0.0
var _time_not_drifting := 0.0
var _time_drifting_side := 0.0
var _time_drifting_total := 0.0

@onready var _car: Car = get_parent()


func _ready() -> void:
	_car.connect("body_entered", _handle_body_enter)
	EventBus.player_enter_drift_zone.connect(_on_enter_drift_zone)
	EventBus.player_exit_drift_zone.connect(_on_exit_drift_zone)
	

func _on_enter_drift_zone(player: Car, drift_zone: DriftZone):
	if is_drift_zone_active:
		return
	is_drift_zone_active = true
	drift_zone_points = 0.0
	points = 0.0
	

func _on_exit_drift_zone(player: Car, drift_zone: DriftZone, is_success: bool, _points: int):
	is_drift_zone_active = false
	drift_zone_points = 0.0


func _handle_body_enter(body: PhysicsBody2D):
	if body and body.get("mass") and body.mass < _car.mass * 0.8:
		return

	_complete_drift()


func _physics_process(delta: float):
	if _cooldown > 0:
		_cooldown -= delta
		return

	var drift_angle_abs: float = abs(_car.drive_angle)
	var new_drift_side := 0.0

	if drift_angle_abs > min_drift_angle && _car.speed > min_drift_speed:
		new_drift_side = sign(_car.drive_angle)

	_update_drift_side(new_drift_side)

	if _drift_side == 0.0:
		_time_not_drifting += delta

		if points > 0.0 and _time_not_drifting > time_to_complete_drift:
			_complete_drift(true)
	else:
		_time_not_drifting = 0.0
		_time_drifting_side += delta
		_time_drifting_total += delta

		var points_earned := 0.0

		points_earned += (
			clamp(inverse_lerp(min_drift_angle, max_drift_angle, drift_angle_abs), 0.0, 1.0)
			* points_for_angle
		)

		points_earned += (
			clamp(inverse_lerp(min_drift_speed, max_drift_speed, _car.speed), 0.0, 1.0)
			* points_for_speed
		)

		add_points(points_earned * delta)


func add_points(amount: float):
	if points == 0:
		EventBus.player_start_drift.emit(_car)
	points += amount
	if amount > 0.0:
		EventBus.player_drift_points.emit(_car, round(points))
		if is_drift_zone_active:
			EventBus.player_drift_zone_points.emit(_car, get_total_drift_zone_points())


func get_total_drift_zone_points():
	return round(points + drift_zone_points)


func _update_drift_side(side: float):
	if side == _drift_side:
		return

	if (
		side != 0
		and _last_drift_side != 0
		and side != _last_drift_side
		and _time_not_drifting < switch_bonus_side_change_time
		and _time_drifting_side > switch_bonus_side_time
	):
		add_points(points_switch_bonus)
		
		#Events.emit_signal(
			#"vehicle_drift_points_bonus", _car, round(points_switch_bonus), points
		#)

	if _drift_side != 0:
		_last_drift_side = _drift_side

	if side != 0:
		_time_drifting_side = 0.0

	_drift_side = side


func _complete_drift(is_success: bool = false):
	_cooldown = time_cooldown
	EventBus.player_end_drift.emit(_car, is_success, round(points))
	if is_success:
		if is_drift_zone_active:
			drift_zone_points += points
		#emit_signal("points_earned", round(points))

	points = 0.0
	_last_drift_side = 0.0
	_time_drifting_total = 0.0
	_time_drifting_side = 0.0
