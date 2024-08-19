extends Node

signal player_start_drift(player: Car)
signal player_end_drift(player: Car, is_success: bool, points: int)
signal player_drift_points(player: Car, points: int)

signal player_enter_drift_zone(player: Car)
signal player_exit_drift_zone(player: Car, is_success: bool, points: int)
signal player_drift_zone_points(player: Car, points: int)
