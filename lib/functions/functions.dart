import 'dart:math';
import 'package:flutter_chess_board/flutter_chess_board.dart';

import '../chess/chess.dart';

// converts raw coordinates of the board where the user tapped on to board square cooridnates
Point getTapPositionOnBoard(Point tapPosition, double squareSize){
  int tapSquareXInt = ((tapPosition.x ~/ squareSize)+1);
  int tapSquareYInt = (8-((tapPosition.y ~/ squareSize)));
  return Point(tapSquareXInt, tapSquareYInt);
}

// checks if a move going from sourceSquareName to sourceSquareName can be a promotion move
bool promotionMoveIsPossible(ChessBoardController chessController, String sourceSquareName, String destinationSquareName){
  List<Move> moves = chessController.game.generate_moves();
  Map moveToCheck = {"from": sourceSquareName, "to": destinationSquareName, "promotion": "q"};

  for (var i = 0; i < moves.length; i++) {
    if (moveToCheck['from'] == moves[i].fromAlgebraic && moveToCheck['to'] == moves[i].toAlgebraic && moves[i].promotion != null) {
      return true;
    }
  }
  return false;
}