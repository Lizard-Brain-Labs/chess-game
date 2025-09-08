extends Control

var move: Move = null

signal piece_dropped(move: Move)

func _can_drop_data(_position: Vector2, data: Variant) -> bool:
	if data is Piece:
		if data.name == move.piece.name:
			return true
	return false

func _drop_data(_position: Vector2, _piece: Variant) -> void:
	emit_signal("piece_dropped", move)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			emit_signal("piece_dropped", move)
