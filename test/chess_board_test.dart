
import 'package:flutter_chess_board/flutter_chess_board.dart';
import 'package:flutter_test/flutter_test.dart';


void main() {
  group('generate_fen tests', () {
    test('generates FEN correctly with no en passant', () {
      ChessBoardController chessBoardController = ChessBoardController();
      chessBoardController.makeMoveWithNormalNotation("h3");
      print(chessBoardController.game.fen);
      chessBoardController.makeMoveWithNormalNotation("h6");
      print(chessBoardController.game.fen);
      chessBoardController.makeMoveWithNormalNotation("a3");
      print(chessBoardController.game.fen);
      chessBoardController.makeMoveWithNormalNotation("h5");
      print(chessBoardController.game.fen);
      chessBoardController.makeMoveWithNormalNotation("a4");
      print(chessBoardController.game.fen);
      chessBoardController.makeMoveWithNormalNotation("h4");
      print(chessBoardController.game.fen);
      chessBoardController.makeMoveWithNormalNotation("g4");
      print(chessBoardController.game.fen);
      chessBoardController.makeMoveWithNormalNotation("a6");
      print(chessBoardController.game.fen);

      chessBoardController.game.fen;

    });
  });
}