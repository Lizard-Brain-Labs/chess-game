extends Node2D

@onready var board = $chessboard
var selected_piece : Piece = null
var selected_square : ColorRect
var end_square: ColorRect

const files = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h']
const piece_order = ["rook", "knight", "bishop", "queen", "king", "bishop", "knight", "rook"]
const piece_scenes = {
	"pawn_white": preload("res://pieces/pawn_white.tscn"),
	"pawn_black": preload("res://pieces/pawn_black.tscn"),
	"rook_white": preload("res://pieces/rook_white.tscn"),
	"rook_black": preload("res://pieces/rook_black.tscn"),
	"knight_white": preload("res://pieces/knight_white.tscn"),
	"knight_black": preload("res://pieces/knight_black.tscn"),
	"bishop_white": preload("res://pieces/bishop_white.tscn"),
	"bishop_black": preload("res://pieces/bishop_black.tscn"),
	"queen_white": preload("res://pieces/queen_white.tscn"),
	"queen_black": preload("res://pieces/queen_black.tscn"),
	"king_white": preload("res://pieces/king_white.tscn"),
	"king_black": preload("res://pieces/king_black.tscn")
} 
func _on_piece_clicked(piece: Piece) -> void:
	selected_piece = piece
	print(piece.type, " ", piece.color)

func _ready():
	# load default position
	for i in files.size():
		var file = files[i]
		# add pawns
		add_piece(file + '2', "pawn", "white")
		add_piece(file + '7', "pawn", "black")
		# add back rank pieces
		add_piece(file + '1', piece_order[i], "white")
		add_piece(file + '8', piece_order[i], "black")
		
func _physics_process(_delta):
	# select square on every click
	if Input.is_action_just_pressed("left_click"):
		if selected_square:
			selected_square.self_modulate = Color.WHITE
		selected_square = board.square_from_pos(board.get_local_mouse_position())
		selected_square.self_modulate = Color.CORNFLOWER_BLUE
		print(selected_square.name, Vector2i(selected_square.rank, selected_square.file))
	
	# move piece to mouse position if held
	if Input.is_action_pressed("left_click"):
		var centered_mouse_pos = board.get_local_mouse_position() - Vector2(32,32)
		if selected_piece:
			selected_piece.position = centered_mouse_pos
			var moves = selected_piece.possible_moves(selected_square)
			for move in moves:
				var square = board.square_from_cell(move)
				square.self_modulate = Color.LIGHT_SALMON
		
	# let go of piece and snap to square
	if Input.is_action_just_released("left_click"):
		var mouse_pos = board.get_local_mouse_position()
		if selected_piece:
			if end_square:
				end_square.self_modulate = Color.WHITE
			end_square = board.square_from_pos(mouse_pos)
			end_square.self_modulate = Color.CORNFLOWER_BLUE
			selected_piece.position = end_square.position
			selected_piece = null

func add_piece(square_name, piece, color):
	var piece_name = piece + "_" + color
	var new_piece = piece_scenes[piece_name].instantiate()
	var n = 1
	while name_exists(piece_name):
		if n > 1:
			piece_name = piece_name.left(len(piece_name) -1)
		piece_name = piece_name + str(n)
		n += 1
		
	new_piece.name = piece_name
	var square = board.squares[square_name]	
	new_piece.position = square.position
	board.add_child(new_piece)
	new_piece.piece_clicked.connect(_on_piece_clicked)
	
func name_exists(name):
	var name_exists = false
	for child in board.get_children():
		if name == child.name:
			name_exists = true
	return name_exists
	
