class_name Square extends ColorRect
# Represents a square on the chess board

var cell: Vector2i

signal empty_square_clicked(square: Square)

func _init(set_cell: Vector2i, sq_size: int, sq_color: Color) -> void:
    cell = set_cell
    name = "%s%d" % [char(cell.y + 97), 8 - cell.x]
    size = Vector2(sq_size, sq_size)
    color = sq_color

func _gui_input(event: InputEvent) -> void:
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
            emit_signal("empty_square_clicked")