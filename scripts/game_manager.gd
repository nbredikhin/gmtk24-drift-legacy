class_name GameManager
extends Node

var reputation := 0


func _ready():
	pass
	#RenderingServer.set_default_clear_color(Color.BLACK)


func _process(delta):
	pass


func add_reputation(amount: int): 
	reputation += amount
	EventBus.reputation_changed.emit(reputation)
