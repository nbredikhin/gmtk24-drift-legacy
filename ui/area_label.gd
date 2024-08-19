extends Label


func _ready() -> void:
	visible = false
	EventBus.player_enter_level_area.connect(_on_enter)


func _on_enter(area: LevelArea):
	text = area.area_title
	var tween = create_tween()
	tween.tween_property(self, "visible", true, 1.1)
	tween.tween_property(self, "visible", false, 6.0)
