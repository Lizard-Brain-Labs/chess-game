extends Node2D

@onready var board = $"board anchor/Pieces TileMap"
@onready var board_origin = $"board anchor"

var moving = false
var moving_piece = null

func _process(delta: float) -> void:	
	# User select piece
	if Input.is_action_just_pressed("left_click"):	
		var mouse_local = board.get_local_mouse_position()
		var board_cell = board.local_to_map(mouse_local)
		#var cell_pos_local = board.map_to_local(board_cell)
		if board_cell.x >= 0 and board_cell.x < 8 and board_cell.y >= 0 and board_cell.y < 8:
			print("")
			var clicked_piece = Piece.new(board_cell)
			var piece = board.get_cell_tile_data(board_cell)
			print("Square is " + clicked_piece.position)
			if piece:
				print(piece.get_custom_data("color") + " " + piece.get_custom_data("piece"))
		
		
		
		
