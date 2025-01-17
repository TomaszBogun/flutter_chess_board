import 'dart:math';
import 'package:flutter_chess_board/flutter_chess_board.dart';

import '../chess/chess.dart';

Point getTapPositionOnBoard(Point tapPosition, double squareSize){
  int tapSquareXInt = ((tapPosition.x ~/ squareSize)+1);
  int tapSquareYInt = (8-((tapPosition.y ~/ squareSize)));
  return Point(tapSquareXInt, tapSquareYInt);
}

bool promotionMoveIsPossible(ChessBoardController chessController, String sourceSquareName, String destinationSquareName){
  Color moveColorBeforeMove = chessController.game.turn;
  chessController.makeMoveWithPromotion(from: sourceSquareName, to: destinationSquareName, pieceToPromoteTo: "q",);
  Color moveColorAfterMove = chessController.game.turn;
  if(moveColorBeforeMove != moveColorAfterMove){
    chessController.game.undo_move();
    return true;
  }
  return false;
}