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
var selected_square : Square
var end_square: Square
var move_choices = {}
var markers:Array[Control] = []
var board_state : BoardState
var white_turn = true

func _ready():
	# load default position
	for file in range(8):
		# add pawns
		add_piece(board.squares[Vector2i(6, file)], "pawn", "white")
		add_piece(board.squares[Vector2i(1, file)], "pawn", "black")
		# add back rank pieces
		add_piece(board.squares[Vector2i(7, file)], piece_order[file], "white")
		add_piece(board.squares[Vector2i(0, file)], piece_order[file], "black")
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
	_remove_markers()

func _handle_mouse_click() -> void:
	_clear_selected_square_highlight()
	if selected_piece:
		selected_square = selected_piece.square
		selected_square.self_modulate = Color.SLATE_GRAY
		var moves = MoveGenerator.get_moves(selected_piece, board_state)
		for move: Move in moves:
			add_marker(board.squares[move.to])
			move_choices[move.to] = move

func _drag_selected_piece():
	if selected_piece:
		selected_piece.position = board.get_local_mouse_position() - Vector2(32,32)
		
func _release_piece():
	if not selected_piece:
		return

	end_square = board.square_from_pos(board.get_local_mouse_position())
	var valid = _is_valid_move_to(end_square)
	if valid:
		var move = move_choices[end_square.cell]
		_move_selected_piece(move)
	else:
		_reset_piece_to_selected_square()
		
	
func _is_valid_move_to(square: Square) -> bool:
	for move_choice in move_choices.values():
		if move_choice.to == square.cell:
			return true
	return false

func _move_selected_piece(move: Move) -> void:
	var to_square = board.squares[move.to]
	var piece = move.piece
	print("Moving ", piece.name, " to ", to_square.name)
	print("Debug: From ", move.from, " to ", move.to, " piece: ", move.piece.name, " captured: ", move.captured_piece, " castle: ", move.castle)
	board.squares[move.from].self_modulate = Color.SLATE_GRAY
	piece.position = to_square.position
	piece.square = to_square
	piece.has_moved = true
	if move.captured_piece:
		print("Capturing ", move.captured_piece.name)
		move.captured_piece.queue_free()
	elif move.castle:
		print("Castling, moving rook")
		_move_selected_piece(move.castle)
	_cleanup_post_move()
	_next_turn()
	
func _reset_piece_to_selected_square():
	selected_piece.position = selected_square.position

func _cleanup_post_move():
	selected_piece = null
	_remove_markers()
	board_state = BoardState.from_board_scene(board)
	print("Debug: Board state updated")
	
func _clear_selected_square_highlight():
	if selected_square:
		selected_square.self_modulate = Color.WHITE

func _clear_end_square_highlight():
	if end_square:
		end_square.self_modulate = Color.WHITE

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
	print("Adding piece ", new_piece.name, " at ", square.cell)
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
	move_choices.clear()
	
func _next_turn() -> void:
	white_turn = not white_turn
	if white_turn:
		debug_label.text = "White to move"
	else:
		debug_label.text = "Black to move"
	
