import 'package:flutter/cupertino.dart';
import '../chess/chess.dart';

enum BoardPieceResolutionSize{
  low,
  high
}

const Map<String,String> lowResMap = {
  "WP": "images/white-pawn-64_x_64.png",
  "WR": "images/white-rook-64_x_64.png",
  "WN": "images/white-knight-64_x_64.png",
  "WB": "images/white-bishop-64_x_64.png",
  "WQ": "images/white-queen-64_x_64.png",
  "WK": "images/white-king-64_x_64.png",
  "BP": "images/black-pawn-64_x_64.png",
  "BR": "images/black-rook-64_x_64.png",
  "BN": "images/black-knight-64_x_64.png",
  "BB": "images/black-bishop-64_x_64.png",
  "BQ": "images/black-queen-64_x_64.png",
  "BK": "images/black-king-64_x_64.png",
};

const Map<String,String> highResMap = {
  "WP": "images/white-pawn-256_x_256.png",
  "WR": "images/white-rook-256_x_256.png",
  "WN": "images/white-knight-256_x_256.png",
  "WB": "images/white-bishop-256_x_256.png",
  "WQ": "images/white-queen-256_x_256.png",
  "WK": "images/white-king-256_x_256.png",
  "BP": "images/black-pawn-256_x_256.png",
  "BR": "images/black-rook-256_x_256.png",
  "BN": "images/black-knight-256_x_256.png",
  "BB": "images/black-bishop-256_x_256.png",
  "BQ": "images/black-queen-256_x_256.png",
  "BK": "images/black-king-256_x_256.png",
};

// similar to class BoardPiece but uses lower resolution for efficiency
class BoardPiece extends StatelessWidget {
  final String squareName;
  final Chess game;
  final BoardPieceResolutionSize boardPieceResolutionSize;

  const BoardPiece({
    Key? key,
    required this.squareName,
    required this.game,
    required this.boardPieceResolutionSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var square = game.get(squareName);

    if (game.get(squareName) == null) {
      return Container();
    }

    Map<String,String> imagePathMap = boardPieceResolutionSize == BoardPieceResolutionSize.low ? lowResMap : highResMap;
    String piece = (square?.color == ChessColor.WHITE ? 'W' : 'B') + (square?.type.toUpperCase() ?? 'P');
    return Image.asset(imagePathMap[piece]!, package: "flutter_chess_board");
  }
}