class_name Square extends ColorRect
# Represents a square on the chess board

var cell: Vector2i

func _init(set_cell: Vector2i, sq_size: int, sq_color: Color) -> void:
    cell = set_cell
    name = "%s%d" % [char(cell.y + 97), 8 - cell.x]
    size = Vector2(sq_size, sq_size)
    color = sq_color