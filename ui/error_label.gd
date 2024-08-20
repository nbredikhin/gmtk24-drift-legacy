extends Label


func _ready() -> void:
	visible = false
	EventBus.error_message.connect(_on_error)


func _on_error(txt: String):
	text = txt
	visible = true
	var tween = create_tween()
	tween.tween_property(self, "visible", false, 5.0)
