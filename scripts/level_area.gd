class_name LevelArea
extends Area2D

@export var area_title := "Forgot to add name,\nbut it's a jam so\nI guess we're fine"

var player_body: Node2D = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


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


func _on_body_exited(body: Node2D):
	if body != player_body:
		return
		
	player_body = null
