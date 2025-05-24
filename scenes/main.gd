extends Node2D

@onready var board = $chessboard

const files = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h']
const piece_order = ["rook", "knight", "bishop", "queen", "king", "bishop", "knight", "rook"]
const piece_scenes = {
	"white_pawn": preload("res://pieces/pawn_white.tscn"),
	"black_pawn": preload("res://pieces/pawn_black.tscn"),
	"white_rook": preload("res://pieces/rook_white.tscn"),
	"black_rook": preload("res://pieces/rook_black.tscn"),
	"white_knight": preload("res://pieces/knight_white.tscn"),
	"black_knight": preload("res://pieces/knight_black.tscn"),
	"white_bishop": preload("res://pieces/bishop_white.tscn"),
	"black_bishop": preload("res://pieces/bishop_black.tscn"),
	"white_queen": preload("res://pieces/queen_white.tscn"),
	"black_queen": preload("res://pieces/queen_black.tscn"),
	"white_king": preload("res://pieces/king_white.tscn"),
	"black_king": preload("res://pieces/king_black.tscn")	
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
		var clicked_square = board.get_square(mouse_local)
		print(clicked_square.name)
		

func add_piece(square_name, piece, color):
	var new_piece = piece_scenes[color + '_' + piece].instantiate()
	var square = board.squares[square_name]
	new_piece.position = square.position + square.size * 0.5
	board.add_child(new_piece)
	
