extends Area2D

@export var new_zoom := 1.0
@export var camera_offset := Vector2.ZERO


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
		
	var cam = get_tree().get_first_node_in_group("game_camera")


func _on_body_exited(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
