extends Node2D

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
const move_marker = preload("res://scenes/move_marker.tscn")
const colors = Piece.colors

@onready var board = $chessboard
@onready var debug_label: Label = %"debug label"
var selected_piece : Piece = null
var selected_square : Square
var end_square: Square
var markers:Array[Control] = []
var board_state : BoardState
var player_turn: colors = colors.WHITE
var hovered_square: Square = null

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
		pass
	elif Input.is_action_just_released("left_click"):
		pass
	
func _on_piece_clicked(piece: Piece) -> void:
	if piece.color != player_turn:
		return
	if piece == selected_piece:
		selected_piece = null
	else:
		selected_piece = piece
	_remove_markers()

func _on_square_mouse_entered(square: Square) -> void:
	if hovered_square:
		hovered_square.self_modulate = Color.WHITE
	hovered_square = square
	hovered_square.self_modulate = Color.HOT_PINK

func _on_marker_mouse_entered(marker: Control) -> void:
	_clear_end_square()
	end_square = board.squares[marker.move.to]
	end_square.self_modulate = Color.DARK_ORANGE

func on_marker_mouse_exited() -> void:
	_clear_end_square()

func _handle_mouse_click() -> void:
	_clear_selected_square_highlight()
	if selected_piece:
		selected_square = selected_piece.square
		selected_square.self_modulate = Color.SLATE_GRAY
		var moves = MoveGenerator.get_moves(selected_piece, board_state)
		for move: Move in moves:
			add_marker(move)

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
	_cleanup_post_move()
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
	var marker = move_marker.instantiate()
	marker.move = move
	var square = board.squares[move.to]
	marker.position = square.position
	board.add_child(marker)
	marker.piece_dropped.connect(_move_piece)
	marker.mouse_entered.connect(_on_marker_mouse_entered.bind(marker))
	marker.mouse_exited.connect(on_marker_mouse_exited)
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
	
