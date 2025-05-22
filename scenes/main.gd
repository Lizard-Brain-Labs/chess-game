extends Node2D

@onready var board = $chessboard

var files = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h']

var piece_scenes = {
	"white_pawn": preload("res://pieces/pawn_white.tscn"),
	"black_pawn": preload("res://pieces/pawn_black.tscn")
}

func _ready():
	
	# load default position
	for file in files:
		add_piece(file + '2', "pawn", "white")
		add_piece(file + '7', "pawn", "black")

func _process(delta: float) -> void:	
	# User select piece
	if Input.is_action_just_pressed("left_click"):	
		var mouse_local = board.get_local_mouse_position()
		var board_cell = board.local_to_map(mouse_local)

func add_piece(square_name, piece, color):
	var new_piece = piece_scenes[color + '_' + piece].instantiate()
	var square = board.squares[square_name]
	new_piece.position = square.position + square.size * 0.5
	board.add_child(new_piece)
	
