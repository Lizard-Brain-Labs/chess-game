# Class for chess pieces
class_name Piece

const file = ['a','b','c','d','e','f','g','h']

var position: String
var name: String

func _init(tile):
	position = get_position(tile)

func get_position(tile:Vector2) -> String:
	var square = str(file[tile.x]) + str(int(-tile.y) + 8)
	return square
