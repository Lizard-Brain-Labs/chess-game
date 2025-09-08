extends Node2D

# TODO:
	# Persist square hightlights from opponent's last move
	# Check/checkmate/stalemate detection
	# Pawn promotion UI
	# Capture move marker as ring
	# AI opponent
		# Move evaluation
		# random opening sets
	# Fog of war
		# Only show pieces that can be captured next turn
		# Add warning if king is in check
		# Could be more like stratego, can see pieces, but not their type
	# Networked multiplayer
	# Move history log - it would be fun to see the whole game afterwards
	# Better graphics and sound effects
	# Menu, restart game, etc.

const files = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h']
const piece_order = ["rook", "knight", "bishop", "queen", "king", "bishop", "knight", "rook"]
const types = Piece.types
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
const MOVE_MARKER = preload("res://scenes/move_marker.tscn")
const colors = Piece.colors
const MARKER_COLOR = Color(0.7, 0.7, 0.7, 0.7)

@onready var board = $chessboard
@onready var debug_label: Label = %"debug label"
var selected_square : Square
var end_square: Square
var markers:Array[Control] = []
var player_turn: colors = colors.WHITE

func _ready():
	# load default position
	for file in range(8):
		# add pawns
		add_piece(board.squares[Vector2i(6, file)], "pawn", "white")
		add_piece(board.squares[Vector2i(1, file)], "pawn", "black")
		# add back rank pieces
		add_piece(board.squares[Vector2i(7, file)], piece_order[file], "white")
		add_piece(board.squares[Vector2i(0, file)], piece_order[file], "black")
	board.board_state = BoardState.from_board_scene(board, player_turn)

	for square in board.squares.values():
		square.empty_square_clicked.connect(_on_empty_square_clicked)

func _on_piece_clicked(piece: Piece) -> void:
	_remove_markers()
	if piece.color != player_turn:
		return
	else:
		_clear_selected_square_highlight()
		selected_square = piece.square
		selected_square.self_modulate = Color.OLIVE_DRAB
		var moves = MoveGenerator.get_moves(piece, board.board_state)
		for move: Move in moves:
			add_marker(move)

func _on_empty_square_clicked() -> void:
	_remove_markers()
	_clear_selected_square_highlight()	

func _on_marker_mouse_entered(marker: Control) -> void:
	_clear_end_square()
	end_square = board.squares[marker.move.to]
	end_square.self_modulate = Color.DARK_SLATE_BLUE
	marker.get_child(0).self_modulate = Color.TRANSPARENT

func _on_marker_mouse_exited(marker: Control) -> void:
	_clear_end_square()
	marker.get_child(0).self_modulate = MARKER_COLOR


func _move_piece(move: Move) -> void:
	var to_square = board.squares[move.to]
	var piece = move.piece
	print("Moving ", piece.name, " to ", to_square.name)
	board.squares[move.from].self_modulate = Color.SLATE_GRAY
	piece.position = to_square.position
	piece.square = to_square
	piece.has_moved = true
	if move.captured_piece:
		print("Capturing ", move.captured_piece.name)
		move.captured_piece.queue_free()
	elif move.en_passant_eligible:
		piece.can_en_passant = true
		print(piece.name, " can be captured en passant next turn")
	elif move.castle:
		print("Castling, moving rook:")
		_move_piece(move.castle)
		return # avoid double cleanup and turn advance
	_remove_markers()
	_next_turn()
	
func _clear_selected_square_highlight():
	if selected_square:
		selected_square.self_modulate = Color.WHITE

func _clear_end_square():
	if end_square:
		end_square.self_modulate = Color.WHITE
		end_square = null

func add_piece(square: Square, piece_type: String, color: String):
	var piece_name = piece_type + "_" + color
	var new_piece: Piece = piece_scenes[piece_name].instantiate()
	piece_name = piece_name + str(0)
	var n = 1
	while name_exists(piece_name):
		if n > 0:
			piece_name = piece_name.left(len(piece_name) -1)
		piece_name = piece_name + str(n)
		n += 1
		
	new_piece.name = piece_name
	new_piece.position = square.position
	new_piece.square = square
	board.add_child(new_piece)
	new_piece.piece_clicked.connect(_on_piece_clicked)
	
func name_exists(piece_name):
	var piece_name_exists = false
	for child in board.get_children():
		if piece_name == child.name:
			piece_name_exists = true
	return piece_name_exists
	
func add_marker(move:Move) -> void:
	var marker = MOVE_MARKER.instantiate()
	marker.move = move
	var square = board.squares[move.to]
	marker.position = square.position
	board.add_child(marker)
	marker.piece_dropped.connect(_move_piece)
	marker.mouse_entered.connect(_on_marker_mouse_entered.bind(marker))
	marker.mouse_exited.connect(_on_marker_mouse_exited.bind(marker))
	markers.append(marker)
	
func _remove_markers() -> void:
	for marker in markers:
		marker.queue_free()
	markers = []
	
func _next_turn() -> void:
	if player_turn == colors.WHITE:
		player_turn = colors.BLACK
		debug_label.text = "Black to move"
	else:
		player_turn = colors.WHITE
		debug_label.text = "White to move"

	# clear en passant eligible for opponent's pawns
	for piece in board.get_children():
		if piece is Piece and piece.type == types.PAWN and piece.color == player_turn:
			piece.can_en_passant = false

	board.board_state = BoardState.from_board_scene(board, player_turn)
	
