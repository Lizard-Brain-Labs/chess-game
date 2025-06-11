class_name Piece extends Control

signal piece_clicked(piece: Piece)

@export var type: String
@export var color: String
@export var square_name: String

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			emit_signal("piece_clicked", self)

func possible_moves(square) -> Array:
	var moves = []
	var loc = Vector2i(square.rank, square.file)
	print(square.rank)
	
	if self.type == "pawn":
		if self.color == "white":
			moves.append(loc + Vector2i.LEFT)
			if square.rank == 6:
				moves.append(loc + Vector2i.LEFT * 2)
		if self.color == "black":
			moves.append(loc + Vector2i.RIGHT)
			if square.rank == 1:
				moves.append(loc + Vector2i.RIGHT * 2)
	
	return moves
