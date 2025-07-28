class_name Piece extends Control

signal piece_clicked(piece: Piece)

@export var type: String
@export var color: String
var square_name: String
var square_grid: Vector2i

# Convenience constants oriented the correct direction for Y up
const UP = Vector2i.LEFT
const DOWN = Vector2i.RIGHT
const LEFT = Vector2i.DOWN
const RIGHT = Vector2i.UP

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			emit_signal("piece_clicked", self)

func possible_moves(square) -> Array:
	var moves = []
	var piece_square = Vector2i(square.rank, square.file)
	
	if self.type == "pawn":
		if self.color == "white":
			moves.append(piece_square + UP)
			if square.rank == 6:
				moves.append(piece_square + UP * 2)
		if self.color == "black":
			moves.append(piece_square + DOWN)
			if square.rank == 1:
				moves.append(piece_square + DOWN * 2)
	
	return moves
