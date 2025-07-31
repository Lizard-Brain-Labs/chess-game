# MoveGenerator.gd
# Static Utility class for generating psuedo-legal moves for pieces.
class_name MoveGenerator

const NORTH = Vector2i.LEFT
const SOUTH = Vector2i.RIGHT
const WEST = Vector2i.DOWN
const EAST = Vector2i.UP

const NE = NORTH + EAST
const NW = NORTH + WEST
const SE = SOUTH + EAST
const SW = SOUTH + WEST

static func get_moves(piece: Piece, board: BoardState) -> Array:
	match piece.type:
		"pawn":
			return _get_pawn_moves(piece, board)
		"rook":
			return _get_moves_in_directions(
				board, piece, [NORTH, SOUTH, WEST, EAST]
			)
		"bishop":
			return _get_moves_in_directions(
				board, piece, [NE, NW, SE, SW]
			)
		"queen":
			return _get_moves_in_directions(
				board, piece,
				[NORTH, SOUTH, WEST, EAST, NE, NW, SE, SW]
			)
		"knight":
			return _get_knight_moves(piece, board)
		"king":
			return _get_king_moves(piece, board)
		_:
			print("Unknown piece type: %s" % piece.type)
			return []

static func _get_pawn_moves(piece: Piece, board: BoardState) -> Array:
	var moves := []
	var dir = NORTH if piece.color == "white" else SOUTH
	var pos = piece.square_grid
	var next = pos + dir
	if board.is_within_bounds(next) and board.get_piece_at(next) == null:
		moves.append(next)
		# Double move if pawn hasn't moved yet
		var double_next = next + dir
		if not piece.has_moved and board.get_piece_at(double_next) == null:
			moves.append(double_next)
	# Captures
	for diag in [dir + EAST, dir + WEST]:
		var target = pos + diag
		if board.is_within_bounds(target):
			var occupant = board.get_piece_at(target)
			if occupant and occupant.color != piece.color:
				moves.append(target)
	return moves

static func _get_moves_in_directions(
	board: BoardState, piece: Piece, directions: Array, max_distance := 8
) -> Array:
	var moves := []
	for dir in directions:
		var current = piece.square_grid + dir
		var steps = 1
		while board.is_within_bounds(current) and steps <= max_distance:
			var occupant = board.get_piece_at(current)
			if occupant == null:
				moves.append(current)
			elif occupant.color != piece.color:
				moves.append(current)
				break
			else:
				break
			current += dir
			steps += 1
	return moves

static func _get_knight_moves(piece, board: BoardState) -> Array:
	var moves := []
	var jumps = [
		Vector2i(-2, -1), Vector2i(-2, 1), Vector2i(-1, -2), Vector2i(-1, 2),
		Vector2i(1, -2), Vector2i(1, 2), Vector2i(2, -1), Vector2i(2, 1)
	]
	for jump in jumps:
		var target = piece.square_grid + jump
		if board.is_within_bounds(target):
			var occupant = board.get_piece_at(target)
			if occupant == null or occupant.color != piece.color:
				moves.append(target)
	return moves

static func _get_king_moves(piece: Piece, board: BoardState) -> Array:
	var moves = _get_moves_in_directions(
		board, piece, 
		[NORTH, SOUTH, WEST, EAST, NE, NW, SE, SW], 1)
	moves += _get_castling_moves(piece, board)
	return moves

static func _get_castling_moves(piece, board: BoardState) -> Array:
	var moves := []
	if piece.has_moved:
		return moves # King has moved, can't castle

	var row = piece.square_grid.x
	var col = piece.square_grid.y
	var color = piece.color

	# Kingside castling
	var kingside_rook_pos = Vector2i(row, 7)
	var kingside_rook = board.get_piece_at(kingside_rook_pos)
	if kingside_rook and kingside_rook.type == "rook" and kingside_rook.color == color and not kingside_rook.has_moved:
		var clear = true
		for y in range(col + 1, 7):
			if board.get_piece_at(Vector2i(row, y)) != null:
				clear = false
				break
		if clear:
			moves.append(Vector2i(row, col + 2))

	# Queenside castling
	var queenside_rook_pos = Vector2i(row, 0)
	var queenside_rook = board.get_piece_at(queenside_rook_pos)
	if queenside_rook and queenside_rook.type == "rook" and queenside_rook.color == color and not queenside_rook.has_moved:
		var clear = true
		for y in range(col - 1, 0, -1):
			if board.get_piece_at(Vector2i(row, y)) != null:
				clear = false
				break
		if clear:
			moves.append(Vector2i(row, col - 2))

	return moves
