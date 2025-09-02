class_name Move
# Represents a chess move action

var from: Vector2i
var to: Vector2i
var piece: Piece
var captured_piece: Piece
var castle: Move # A secondary move for castling (rook move)
var en_passant_eligible: bool
var promotion_type: String

func _init(
    mv_piece: Piece,
    mv_to: Vector2i, 
    mv_captured_piece: Piece = null,
    mv_castle: Move = null,
    mv_enables_en_passant: bool = false,
    mv_promotion_type: String = "",
):
    self.from = mv_piece.square.cell
    self.to = mv_to
    self.piece = mv_piece
    self.captured_piece = mv_captured_piece
    self.castle = mv_castle
    self.en_passant_eligible = mv_enables_en_passant
    self.promotion_type = mv_promotion_type