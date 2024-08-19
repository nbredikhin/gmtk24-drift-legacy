class_name GameManager
extends Node

var reputation := 0
var is_first_drift_zone_completed := false


func _ready():
	$CanvasLayer.visible = true
	RenderingServer.set_default_clear_color(Color.BLACK)
	
	EventBus.player_dialogue.emit("dialogue_example")
	EventBus.player_exit_drift_zone.connect(_on_exit_drift_zone)


#func _process(delta):
	#pass


func _on_exit_drift_zone(player: Car, zone: DriftZone, is_success: bool, points: int):
	if is_success and not is_first_drift_zone_completed:
		is_first_drift_zone_completed = true
		EventBus.player_dialogue.emit("dialogue_first_drift_zone")


func add_reputation(amount: int): 
	reputation += amount
	EventBus.reputation_changed.emit(reputation)
