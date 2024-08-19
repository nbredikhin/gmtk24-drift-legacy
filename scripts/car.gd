class_name Car
extends RigidBody2D

const MAX_ENGINE_BRAKE_SPEED = 30.0

var input_acceleration = 0.0
var input_steering = 0.0
var input_brake = 0.0

var max_speed := 130.0
var max_acceleration := 1.5
var max_engine_brake := 1.0
var max_tire_friction := 3.0
var max_steering_speed := 35.0

var steering_min_speed := 5.0
var steering_low_speed := 30.0

var drive_angle := 0.0
var speed := 0.0

var _local_velocity := Vector2.ZERO


func _process(delta):
	input_acceleration = Input.get_axis("move_down", "move_up")
	input_steering = Input.get_axis("move_left", "move_right")
	input_brake = Input.get_action_strength("brake")


func _physics_process(delta):
	_update_steering()
	_update_drive()


func _update_drive() -> void:
	speed = linear_velocity.length()
	_local_velocity = to_local(global_position - linear_velocity)

	drive_angle = rad_to_deg(_local_velocity.angle() - PI * 0.5)

	var engine_force := 0.0
	var acceleration_mul := 1.0 # acceleration_curve.interpolate_baked(_speed / max_speed)
	engine_force += input_acceleration * max_acceleration * acceleration_mul

	var engine_brake_mul = clamp(
		abs(input_acceleration) + abs(input_steering) + input_brake, 0.0, 1.0
	)
	engine_force -= (
		(1.0 - min(1.0, engine_brake_mul))
		* max_engine_brake
		* clamp(_local_velocity.y / MAX_ENGINE_BRAKE_SPEED, -1.0, 1.0)
	)

	var drive_force := Vector2.ZERO

	drive_force += Vector2.UP * engine_force
	var tire_friction = clamp(_local_velocity.x * max_tire_friction, -max_tire_friction, max_tire_friction)
	tire_friction *= 1.0 - input_brake
	drive_force += Vector2.RIGHT * tire_friction

	apply_central_impulse(global_transform.basis_xform(drive_force))


func _update_steering() -> void:
	var steering_torque := 0.0
	var steering_mul := 1.0
	if speed < steering_min_speed:
		steering_mul = 0.0
	elif speed < steering_low_speed:
		steering_mul = (speed - steering_min_speed) / (steering_low_speed - steering_min_speed)
		steering_mul = pow(steering_mul, 1.3)

	# Handle reverse steering
	if abs(drive_angle) > 130.0 and input_acceleration < 0.0 and input_brake < 1.0:
		steering_mul *= -1.0

	steering_torque = input_steering * steering_mul * max_steering_speed

	apply_torque_impulse(steering_torque)
