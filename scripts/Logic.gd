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
		print(piece_pos.x)
		if piece_data.color == "white":
			moves.append(piece_pos + UP)
			if piece_pos.x == 6:
				moves.append(piece_pos + UP * 2)
		if piece_data.color == "black":
			moves.append(piece_pos + DOWN)
			if piece_pos.x == 1:
				moves.append(piece_pos + DOWN * 2)
	
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
	
