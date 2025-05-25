extends Node2D

@export var square_size = 64
@export var board_color_light = Color("#EEEED2")  # light
@export var board_color_dark = Color("#769656")  # dark

var squares = {}

func _ready():
	var board_size = Vector2(square_size * 8, square_size * 8)
	var viewport_center = get_viewport_rect().size*0.5
	position = viewport_center - board_size*0.5
	
	_create_board()
	
func _create_board():
	for rank in range(0,8):
		for file in range(0,8):
			var square = ColorRect.new()
			if (rank + file) % 2 == 0:
				square.color = board_color_light
			else:
				square.color = board_color_dark
			square.size = Vector2(square_size, square_size)
			square.position = Vector2(file * square_size, rank * square_size)
			square.name = "%s%d" % [char(file + 97), 8 - rank]
			squares[square.name] = square
			add_child(square)
	
func square_from_pos(pos:Vector2) -> ColorRect:
	var rank = int(pos.y / 64)
	var file = int(pos.x / 64)
	var square_name = "%s%d" % [char(file + 97), 8 - rank]
	return squares[square_name]
	
func piece_on_square(square):
	var pos = square.position
	for child in self.get_children():
		print(child.name + str(child.position))
		if child is not ColorRect and child.position == pos:
			print(child.name)
	
