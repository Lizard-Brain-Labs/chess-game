class_name Logic

# Convenience constants oriented the correct direction for Y up
const UP = Vector2i.LEFT
const DOWN = Vector2i.RIGHT
const LEFT = Vector2i.DOWN
const RIGHT = Vector2i.UP

static func get_moves(piece_data, board: BoardState) -> Array:
	var moves := []
	var piece_pos = piece_data.square_grid
	if piece_data.type == "pawn":
		var dir = UP
		if piece_data.color == "black":
			dir = DOWN
		var current = piece_pos + dir
		var occupant = board.get_piece_at(current)
		if occupant == null:
			moves.append(current)
			if (piece_pos.x == 6 and dir == UP) or (piece_pos.x == 1 and dir == DOWN): #starting row
				current += dir
				occupant = board.get_piece_at(current)
				if occupant == null:
					moves.append(current)
	
	if piece_data.type == "rook":
		var directions = [UP,DOWN,LEFT,RIGHT]
		for dir in directions:
			var current = piece_data.square_grid + dir
			while board.is_within_bounds(current):
				var occupant = board.get_piece_at(current)
				if occupant == null:
					moves.append(current)
				elif occupant.color != piece_data.color:
					moves.append(current)
					break
				else:
					break  # friendly piece blocks path
				current += dir

	return moves
	
