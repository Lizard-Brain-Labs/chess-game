class_name Square extends Control

var cell: Vector2i

func _init(set_cell: Vector2i, sq_size: int, sq_color: Color) -> void:
    cell = set_cell
    name = "%s%d" % [char(cell.y + 97), 8 - cell.x]
    size = Vector2(sq_size, sq_size)
    var rect = ColorRect.new()
    rect.color = sq_color
    rect.size = Vector2(sq_size, sq_size)
    add_child(rect)

# now we can use mouse enter/exit signals on squares to easily handle deselecting pieces

