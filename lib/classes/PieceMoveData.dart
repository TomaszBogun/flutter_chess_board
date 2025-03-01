import 'package:flutter_chess_board/chess/chess.dart';

class PieceMoveData {
  final String squareName;
  final String pieceType;
  final ChessColor pieceColor;

  PieceMoveData({
    required this.squareName,
    required this.pieceType,
    required this.pieceColor,
  });
}