extends Area2D

@export var new_zoom := 1.0
@export var camera_offset := Vector2.ZERO

var _dialogue_timeout = 4.0
var _is_dialogue_pending := false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if _is_dialogue_pending:
		_dialogue_timeout -= delta
		if _dialogue_timeout <= 0:
			EventBus.player_dialogue.emit("dialogue_final")
			_is_dialogue_pending = false


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
		
	var cam = get_tree().get_first_node_in_group("game_camera")
	cam.set_zoom_out(new_zoom, camera_offset)
	_is_dialogue_pending = true


func _on_body_exited(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	
	var cam = get_tree().get_first_node_in_group("game_camera")
	cam.clear_zoom_out()
