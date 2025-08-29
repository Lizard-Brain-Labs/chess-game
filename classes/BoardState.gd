class_name BoardState
# Represents the state of a chess board in data

const BOARD_SIZE = 8

var grid := []

func _init():
	grid.resize(BOARD_SIZE)
	for x in range(BOARD_SIZE):
		grid[x] = []
		for y in range(BOARD_SIZE):
			grid[x].append(null)

# Returns the piece data at a given position, or null
func get_piece_at(pos: Vector2i):
	if is_within_bounds(pos):
		return grid[pos.x][pos.y]
	return null

# Utility
func is_within_bounds(pos: Vector2i) -> bool:
	return pos.x >= 0 and pos.x < BOARD_SIZE and pos.y >= 0 and pos.y < BOARD_SIZE

# Build a board state from a scene-based board (after a move)
static func from_board_scene(board_node: Node2D) -> BoardState:
	var state = BoardState.new()
	
	for piece in board_node.get_children():
		if not piece is Piece:
			continue

		var piece_pos = piece.square_grid
		state.grid[piece_pos.x][piece_pos.y] = piece
	return state
	
