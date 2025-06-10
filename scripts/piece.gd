class_name Piece extends Control

signal piece_clicked(piece: Piece)

@export var type: String
@export var color: String

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			emit_signal("piece_clicked", self)

func possible_moves(square) -> Array:
	var moves = []
	var loc = Vector2i(square.rank, square.file)
	
	if self.type == "pawn":
		var pos = loc + Vector2i.LEFT
		moves.append(pos)
	
	return moves
