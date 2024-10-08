class_name GameManager
extends Node

var reputation := 0
var is_first_drift_zone_completed := false


func _ready():
	$CanvasLayer.visible = true
	RenderingServer.set_default_clear_color(Color.BLACK)
	
	await get_tree().process_frame
	EventBus.player_dialogue.emit("dialogue_into")
	EventBus.player_exit_drift_zone.connect(_on_exit_drift_zone)


#func _process(delta):
	#pass


func _on_exit_drift_zone(player: Car, zone: DriftZone, is_success: bool, points: int):
	pass
	#if is_success and not is_first_drift_zone_completed:
		#is_first_drift_zone_completed = true
		#EventBus.player_dialogue.emit("dialogue_first_drift_zone")


func add_reputation(amount: int): 
	reputation += amount
	EventBus.reputation_changed.emit(reputation)
