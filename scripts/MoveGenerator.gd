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

const types = Piece.types

static func get_moves(piece: Piece, board_state: BoardState) -> Array[Move]:
	match piece.type:
		types.PAWN:
			return _get_pawn_moves(piece, board_state)
		types.ROOK:
			return _get_moves_in_directions(
				board_state, piece, [NORTH, SOUTH, WEST, EAST]
			)
		types.BISHOP:
			return _get_moves_in_directions(
				board_state, piece, [NE, NW, SE, SW]
			)
		types.QUEEN:
			return _get_moves_in_directions(
				board_state, piece,
				[NORTH, SOUTH, WEST, EAST, NE, NW, SE, SW]
			)
		types.KNIGHT:
			return _get_knight_moves(piece, board_state)
		types.KING:
			return _get_king_moves(piece, board_state)
		_:
			print("Unknown piece type: %s" % piece.type)
			return []

static func _get_pawn_moves(piece: Piece, board_state: BoardState) -> Array:
	var moves: Array[Move] = []
	var dir = NORTH if piece.color == 0 else SOUTH
	var pos = piece.square.cell
	var next = pos + dir
	if board_state.is_within_bounds(next) and board_state.get_piece_at(next) == null:
		moves.append(Move.new(piece, next))
		# Double move if pawn hasn't moved yet
		var double_next = next + dir
		if not piece.has_moved and board_state.get_piece_at(double_next) == null:
			moves.append(Move.new(piece, double_next, null, null, true))
	# Captures
	for diag in [dir + EAST, dir + WEST]:
		var target = pos + diag
		if board_state.is_within_bounds(target):
			var occupant = board_state.get_piece_at(target)
			if occupant and occupant.color != piece.color:
				moves.append(Move.new(piece, target, occupant))
	# En passant
	for side in [EAST, WEST]:
		var side_pos = pos + side
		if board_state.is_within_bounds(side_pos):
			var side_piece = board_state.get_piece_at(side_pos)
			print("Checking en passant for ", piece.name, " against ", side_piece, " at ", side_pos, "\nEligible: ", side_piece.can_en_passant if side_piece else "N/A")
			if side_piece and side_piece.type == types.PAWN and side_piece.color != piece.color and side_piece.can_en_passant:
				var ep_target = side_pos + dir
				moves.append(Move.new(piece, ep_target, side_piece))

	# Promotion ...
	
	return moves

static func _get_moves_in_directions(
	board_state: BoardState, piece: Piece, directions: Array, max_distance := 8
) -> Array:
	var moves : Array[Move] = []
	for dir in directions:
		var current = piece.square.cell + dir
		var steps = 1
		while board_state.is_within_bounds(current) and steps <= max_distance:
			var occupant = board_state.get_piece_at(current)
			if occupant == null:
				moves.append(Move.new(piece, current))
			elif occupant.color != piece.color:
				moves.append(Move.new(piece, current, occupant))
				break
			else:
				break
			current += dir
			steps += 1
	return moves

static func _get_knight_moves(piece, board_state: BoardState) -> Array:
	var moves : Array[Move]= []
	var jumps = [
		Vector2i(-2, -1), Vector2i(-2, 1), Vector2i(-1, -2), Vector2i(-1, 2),
		Vector2i(1, -2), Vector2i(1, 2), Vector2i(2, -1), Vector2i(2, 1)
	]
	for jump in jumps:
		var target = piece.square.cell + jump
		if board_state.is_within_bounds(target):
			var occupant = board_state.get_piece_at(target)
			if occupant == null:
				moves.append(Move.new(piece, target))
			elif occupant.color != piece.color:
				moves.append(Move.new(piece, target, occupant))
	return moves

static func _get_king_moves(piece: Piece, board_state: BoardState) -> Array:
	var moves = _get_moves_in_directions(
		board_state, piece, 
		[NORTH, SOUTH, WEST, EAST, NE, NW, SE, SW], 1)
	moves += _get_castling_moves(piece, board_state)
	return moves

static func _get_castling_moves(piece, board_state: BoardState) -> Array:
	var moves : Array[Move]= []
	if piece.has_moved:
		return moves # King has moved, can't castle

	var row = piece.square.cell.x
	var col = piece.square.cell.y
	var color = piece.color

	# Castling
	var kingside_rook_pos = Vector2i(row, 7)
	var kingside_rook = board_state.get_piece_at(kingside_rook_pos)
	if kingside_rook and kingside_rook.type == types.ROOK and kingside_rook.color == color and not kingside_rook.has_moved:
		var clear = true
		for y in range(col + 1, 7):
			if board_state.get_piece_at(Vector2i(row, y)) != null:
				clear = false
				break
		if clear:
			var king_castle = Move.new(kingside_rook, Vector2i(row, 5))
			moves.append(Move.new(piece, Vector2i(row, col + 2), null, king_castle))

	# Queenside castling
	var queenside_rook_pos = Vector2i(row, 0)
	var queenside_rook = board_state.get_piece_at(queenside_rook_pos)
	if queenside_rook and queenside_rook.type == types.ROOK and queenside_rook.color == color and not queenside_rook.has_moved:
		var clear = true
		for y in range(col - 1, 0, -1):
			if board_state.get_piece_at(Vector2i(row, y)) != null:
				clear = false
				break
		if clear:
			var queen_castle = Move.new(queenside_rook, Vector2i(row, 3))
			moves.append(Move.new(piece, Vector2i(row, col - 2), null, queen_castle))

	return moves
