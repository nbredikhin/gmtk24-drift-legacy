extends Control

var _dialogue_data: DialogueData
var _line_index := 0
var _text_duration := 2.0

func _ready() -> void:
	EventBus.player_dialogue.connect(_on_start_dialogue)
	visible = false


func _on_start_dialogue(dialogue_id: String):
	visible = true
	_dialogue_data = load(str("res://data/dialogues/",dialogue_id,".tres"))
	_line_index = 0
	$NameLabel.text = _dialogue_data.name
	$NameLabel.label_settings.font_color = _dialogue_data.name_color
	if _dialogue_data.avatar:
		$Avatar.texture = _dialogue_data.avatar
	_display_line()
	get_tree().paused = true


func _process(delta: float) -> void:
	if not visible:
		return
		
	$TextLabel.visible_ratio = min(1.0, $TextLabel.visible_ratio + delta / _text_duration)
	
	if Input.is_action_just_pressed("brake"):
		_advance_dialogue()


func _advance_dialogue():
	if _line_index >= _dialogue_data.lines.size() - 1:
		visible = false
		get_tree().paused = false
		return
	
	_line_index += 1
	_display_line()


func _display_line():
	var text = _dialogue_data.lines[_line_index]
	$TextLabel.text = text
	$TextLabel.visible_ratio = 0.0
	_text_duration = max(1.0, text.length() * 0.01)
