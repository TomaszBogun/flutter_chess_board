
import 'package:flutter_chess_board/flutter_chess_board.dart';
import 'package:flutter_test/flutter_test.dart';


const String DEFAULT_POSITION = 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq -';

void main() {

  group("foundational tests", () {
    test("can make object with standard start fen", () {
      ChessBoardController chessBoardController = ChessBoardController();
      assert(chessBoardController.game.fen == DEFAULT_POSITION);
    });

    test("can play moves", (){
      ChessBoardController chessBoardController = ChessBoardController();
      chessBoardController.makeMoveWithNormalNotation("e4");
      chessBoardController.makeMoveWithNormalNotation("e5");
      assert(chessBoardController.game.fen == "rnbqkbnr/pppp1ppp/8/4p3/4P3/8/PPPP1PPP/RNBQKBNR w KQkq -");
    });

    test("can undo moves", (){
      ChessBoardController chessBoardController = ChessBoardController();
      chessBoardController.makeMoveWithNormalNotation("e4");
      chessBoardController.makeMoveWithNormalNotation("e5");
      chessBoardController.game.undo_move();
      chessBoardController.game.undo_move();
      assert(chessBoardController.game.fen == DEFAULT_POSITION);
    });

    test("can make move with promotion", (){
      ChessBoardController chessBoardController = ChessBoardController();
      chessBoardController.makeMoveWithNormalNotation("e4");
      chessBoardController.makeMoveWithNormalNotation("f5");
      chessBoardController.makeMoveWithNormalNotation("exf5");
      chessBoardController.makeMoveWithNormalNotation("g6");
      chessBoardController.makeMoveWithNormalNotation("fxg6");
      chessBoardController.makeMoveWithNormalNotation("Bg7");
      chessBoardController.makeMoveWithNormalNotation("gxh7");
      chessBoardController.makeMoveWithNormalNotation("Bh6");
      assert(chessBoardController.game.fen == "rnbqk1nr/ppppp2P/7b/8/8/8/PPPP1PPP/RNBQKBNR w KQkq -");
      chessBoardController.makeMoveWithNormalNotation("hxg8=R+");
      assert(chessBoardController.game.fen == "rnbqk1Rr/ppppp3/7b/8/8/8/PPPP1PPP/RNBQKBNR b KQkq -");
    });

    test("does not accept invalid moves", (){
      ChessBoardController chessBoardController = ChessBoardController();
      chessBoardController.makeMoveWithNormalNotation("e7"); // invalid move
      // fen not changed
      assert(chessBoardController.game.fen == DEFAULT_POSITION);
    });


    test("can load base fen", (){
      ChessBoardController chessBoardController = ChessBoardController();
      chessBoardController.loadFen("rnbqkbnr/ppppp1pp/8/5p2/4P3/8/PPPP1PPP/RNBQKBNR w KQkq -");
      // fen not changed
      assert(chessBoardController.game.fen == "rnbqkbnr/ppppp1pp/8/5p2/4P3/8/PPPP1PPP/RNBQKBNR w KQkq -");
    });

    test("can load full fen", (){
      ChessBoardController chessBoardController = ChessBoardController();
      chessBoardController.loadFen("rnbqkbnr/ppppp1pp/8/5p2/4P3/8/PPPP1PPP/RNBQKBNR w KQkq - 0 2");
      // base fen showed
      assert(chessBoardController.game.fen == "rnbqkbnr/ppppp1pp/8/5p2/4P3/8/PPPP1PPP/RNBQKBNR w KQkq -");
    });

    test("retrieving san moves works", (){
      ChessBoardController chessBoardController = ChessBoardController();
      chessBoardController.makeMoveWithNormalNotation("e4");
      chessBoardController.makeMoveWithNormalNotation("e5");
      chessBoardController.makeMoveWithNormalNotation("d4");
      chessBoardController.makeMoveWithNormalNotation("d5");
      List<String?> sanMoves = chessBoardController.getSan();
      assert(sanMoves[0] == "1. e4 e5");
      assert(sanMoves[1] == "2. d4 d5");
    });

  });

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
    });
  });
}