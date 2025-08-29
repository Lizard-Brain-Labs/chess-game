extends Node2D

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
const move_marker = preload("res://scenes/move_marker.tscn")
@onready var board = $chessboard
@onready var debug_label: Label = %"debug label"
var selected_piece : Piece = null
var selected_square : ColorRect
var end_square: ColorRect
var move_choices = {}
var markers:Array[Control] = []
var board_state : BoardState
var white_turn = true

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
	board_state = BoardState.from_board_scene(board)
		
func _physics_process(_delta):
	if Input.is_action_just_pressed("left_click"):
		_handle_mouse_click()
	if Input.is_action_pressed("left_click"):
		_drag_selected_piece()
	elif Input.is_action_just_released("left_click"):
		_release_piece()
	
func _on_piece_clicked(piece: Piece) -> void:
	selected_piece = piece

func _handle_mouse_click():
	_clear_selected_square_highlight()
	if selected_piece:
		selected_square = board.squares[selected_piece.square_name]
		selected_square.self_modulate = Color.SLATE_GRAY
		var moves = MoveGenerator.get_moves(selected_piece, board_state)
		for move in moves:
			add_marker(board.square_from_cell(move.to))
			move_choices[move.to] = move

func _drag_selected_piece():
	if selected_piece:
		selected_piece.position = board.get_local_mouse_position() - Vector2(32,32)
		
func _release_piece():
	if not selected_piece:
		return
	
	var target_square = board.square_from_pos(board.get_local_mouse_position())
	_clear_end_square_highlight()
	end_square = target_square
	
	var valid = _is_valid_move_to(end_square.name)
	if valid:
		var move = move_choices[Vector2i(end_square.rank, end_square.file)]
		_move_selected_piece(move, end_square)
	else:
		_reset_piece_to_selected_square()
		
	_cleanup_post_move()
	
func _is_valid_move_to(square_name: String) -> bool:
	for mark in markers:
		if mark.square_name == square_name:
			return true
	return false

func _move_selected_piece(move: Move, square: Square):
	print("Moving ", selected_piece.name, " to ", square.name)
	square.self_modulate = Color.SLATE_GRAY
	selected_piece.position = square.position
	selected_piece.square_name = square.name
	selected_piece.square_grid = Vector2i(square.rank, square.file)
	selected_piece.has_moved = true
	if move.captured_piece:
		print("Capturing ", move.captured_piece.name)
		move.captured_piece.queue_free()
	elif move.castle_rook:
		var rook = move.castle_rook[0]
		var new_rook_square = board.square_from_cell(move.castle_rook[1])
		print("Castling rook ", rook.name, " to ", new_rook_square.name)
		rook.position = new_rook_square.position
		rook.square_name = new_rook_square.name
		rook.square_grid = Vector2i(new_rook_square.rank, new_rook_square.file)
		rook.has_moved = true
	_next_turn()
	
func _reset_piece_to_selected_square():
	selected_piece.position = selected_square.position

func _cleanup_post_move():
	selected_piece = null
	_remove_markers()
	board_state = BoardState.from_board_scene(board)
	
func _clear_selected_square_highlight():
	if selected_square:
		selected_square.self_modulate = Color.WHITE

func _clear_end_square_highlight():
	if end_square:
		end_square.self_modulate = Color.WHITE

func add_piece(square_name, piece, color):
	var piece_name = piece + "_" + color
	var new_piece: Piece = piece_scenes[piece_name].instantiate()
	piece_name = piece_name + str(0)
	var n = 1
	while name_exists(piece_name):
		if n > 0:
			piece_name = piece_name.left(len(piece_name) -1)
		piece_name = piece_name + str(n)
		n += 1
		
	new_piece.name = piece_name
	var square = board.squares[square_name]
	new_piece.position = square.position
	new_piece.square_name = square_name
	new_piece.square_grid = Vector2i(square.rank, square.file)
	board.add_child(new_piece)
	new_piece.piece_clicked.connect(_on_piece_clicked)
	
func name_exists(piece_name):
	var piece_name_exists = false
	for child in board.get_children():
		if piece_name == child.name:
			piece_name_exists = true
	return piece_name_exists
	
func add_marker(square:Square):
	var marker = move_marker.instantiate()
	marker.position = square.position
	marker.square_name = square.name
	board.add_child(marker)
	markers.append(marker)
	
func _remove_markers() -> void:
	for marker in markers:
		marker.queue_free()
	markers = []
	
func _next_turn() -> void:
	white_turn = not white_turn
	if white_turn:
		debug_label.text = "White to move"
	else:
		debug_label.text = "Black to move"
	
