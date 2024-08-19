class_name LevelArea
extends Area2D

@export var area_title := "Forgot to add name,\nbut it's a jam so\nI guess we're fine"
@export var first_enter_dialogue_id := ""

var player_body: Node2D = null
var was_entered := false
var time_in_zone := 0.0
var _pending_dialogue := false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if player_body:
		time_in_zone += delta
		
	if time_in_zone > 0.8 and _pending_dialogue:
		EventBus.player_dialogue.emit(first_enter_dialogue_id)
		_pending_dialogue = false


func _on_body_entered(body: Node2D):
	if body.is_in_group("player") == false:
		return
		
	if player_body != null:
		return
	
	player_body = body
	
	var camera: GameCamera = get_tree().get_first_node_in_group("game_camera")
	if camera != null:
		camera.transition_to_level_area(self)
		
	for area in get_tree().get_nodes_in_group("level_area"):
		if area != self:
			area.player_body = null
	
	time_in_zone = 0
	EventBus.player_enter_level_area.emit(self)

	if was_entered == false:
		was_entered = true
		if first_enter_dialogue_id.is_empty() == false:
			_pending_dialogue = true


func _on_body_exited(body: Node2D):
	if body != player_body:
		return
		
	player_body = null
	time_in_zone = 0
