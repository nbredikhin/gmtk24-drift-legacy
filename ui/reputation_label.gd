extends Label

func _ready() -> void:
	update_amount(0)
	EventBus.reputation_changed.connect(update_amount)

	
func update_amount(amount: int):
	text = str("REP\n",amount)
