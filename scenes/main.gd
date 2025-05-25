extends Node2D

@onready var board = $chessboard

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

func _process(delta: float) -> void:	
	# User select piece
	if Input.is_action_just_pressed("left_click"):	
		var mouse_local = board.get_local_mouse_position()
		var clicked_square = board.square_from_pos(mouse_local)
		print(clicked_square.name)
		board.piece_on_square(clicked_square)
		
		
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
	print(piece_name)
	var square = board.squares[square_name]	
	new_piece.position = square.position + square.size * 0.5
	board.add_child(new_piece)
	
func name_exists(name):
	var name_exists = false
	for child in board.get_children():
		if name == child.name:
			name_exists = true
	return name_exists
