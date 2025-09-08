extends Node2D

@export var square_size = 64
@export var board_color_light = Color("#d4d4a2ff")  # light
@export var board_color_dark = Color("#613838ff")  # dark

var squares = {}
var board_state : BoardState

func _ready():
	var board_size = Vector2i(square_size * 8, square_size * 8)
	var viewport_center = get_viewport_rect().size*0.5
	position = viewport_center - board_size*0.5
	
	_create_board()
	
func _create_board():
	for rank in range(8):
		for file in range(8):
			var color: Color
			if (rank + file) % 2 == 0:
				color = board_color_light
			else:
				color = board_color_dark
			var square = Square.new(Vector2i(rank, file), square_size, color)
			square.position = Vector2i(file * square_size, rank * square_size)
			squares[square.cell] = square
			add_child(square)
	
func square_from_pos(pos:Vector2) -> Square:
	var rank = int(pos.y / 64)
	var file = int(pos.x / 64)
	return squares[Vector2i(rank, file)]
