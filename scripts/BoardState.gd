class_name BoardState

const BOARD_SIZE = 8
# This should always ingest a Piece class which contains these variables
class PieceData:
	var type: String
	var color: String
	var square_grid: Vector2i

	func _init(type: String, color: String, square_grid: Vector2i):
		self.type = type
		self.color = color
		self.square_grid = square_grid

var grid := []

func _init():
	grid.resize(BOARD_SIZE)
	for x in range(BOARD_SIZE):
		grid[x] = []
		for y in range(BOARD_SIZE):
			grid[x].append(null)

# Returns the piece data at a given position, or null
func get_piece_at(pos: Vector2i) -> PieceData:
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

		var type = piece.type
		var color = piece.color
		var square_grid = piece.square_grid
		var pdata = PieceData.new(type, color, square_grid)
		state.grid[square_grid.x][square_grid.y] = pdata
	return state
