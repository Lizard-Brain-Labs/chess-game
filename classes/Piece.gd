class_name Piece extends Control
# Represents a chess piece on the board

const MOVING_COLOR = Color(1, 1, 1, 0.5)

signal piece_clicked(piece: Piece)
enum colors { WHITE, BLACK }
enum types { PAWN, KNIGHT, BISHOP, ROOK, QUEEN, KING }

@export var type: types
@export var color: colors
var square: Square
var has_moved: bool = false
var can_en_passant: bool = false

# Convenience constants oriented the correct direction for Y up
const UP = Vector2i.LEFT
const DOWN = Vector2i.RIGHT
const LEFT = Vector2i.DOWN
const RIGHT = Vector2i.UP

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			emit_signal("piece_clicked", self)

func _get_drag_data(_position: Vector2) -> Piece:
	print("Dragging piece: ", name)
	var preview = self.duplicate(DUPLICATE_USE_INSTANTIATION)
	preview.get_child(0).centered = true
	set_drag_preview(preview)
	modulate = MOVING_COLOR
	return self

func _notification(what: int) -> void:
	if what == NOTIFICATION_DRAG_END:
		modulate = Color.WHITE
