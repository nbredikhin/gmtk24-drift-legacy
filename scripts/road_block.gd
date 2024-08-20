extends StaticBody2D

@export var required_rep := 50
@export var trigger_dialogue_id := ""

func _ready():
	EventBus.reputation_changed.connect(_on_rep_change)
	$LabelContainer.global_position = global_position + Vector2.UP * 5.0
	$LabelContainer.global_rotation = 0.0
	$LabelContainer/Label.text = str(required_rep," REP")


func _on_rep_change(rep: int):
	if rep >= required_rep and $Node2D != null:
		$Node2D.queue_free()
		$CollisionShape2D.queue_free()
		$LabelContainer/Label.text = "AREA UNLOCKED"
		$LabelContainer/Label.label_settings = $LabelContainer/Label.label_settings.duplicate()
		$LabelContainer/Label.label_settings.font_color = Color.DARK_GREEN
		if trigger_dialogue_id.is_empty() == false:
			EventBus.player_dialogue.emit(trigger_dialogue_id)


func _process(delta):
	pass
