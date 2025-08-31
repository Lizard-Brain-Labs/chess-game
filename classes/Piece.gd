class_name Piece extends Control
# Represents a chess piece on the board

signal piece_clicked(piece: Piece)

@export var type: String
@export var color: String
var square: Square
var has_moved: bool = false

# Convenience constants oriented the correct direction for Y up
const UP = Vector2i.LEFT
const DOWN = Vector2i.RIGHT
const LEFT = Vector2i.DOWN
const RIGHT = Vector2i.UP

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			emit_signal("piece_clicked", self)