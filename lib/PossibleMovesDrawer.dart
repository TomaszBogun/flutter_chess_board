import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';

import 'chess/chess.dart' hide Color;
import 'flutter_chess_board.dart';

class PossibleMovesDrawer extends CustomPainter{
  bool isWhite;
  ChessBoardController chessController;
  Point lastTappedPositionOnBoard;

  PossibleMovesDrawer({required this.isWhite, required this.chessController, required this.lastTappedPositionOnBoard});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..strokeWidth=size.width/100;
    paint.color = Color(0x67008800);
    double squareSize = size.width/8;

    if(!isWhite){
      lastTappedPositionOnBoard = Point(9 - lastTappedPositionOnBoard.x, 9 - lastTappedPositionOnBoard.y);
    }

    String file = lastTappedPositionOnBoard.x.toString().replaceAll("1", "a").replaceAll("2", "b").replaceAll("3", "c").replaceAll("4", "d").replaceAll("5", "e").replaceAll("6", "f").replaceAll("7", "g").replaceAll("8", "h");
    String rank = lastTappedPositionOnBoard.y.toString();
    String moveFromAlgebraic = "$file$rank";

    List<Move> possibleMoves = chessController.getPossibleMoves();
    List<Move> possibleMovesFromSquare = [];
    for(Move move in possibleMoves){
      if(move.fromAlgebraic == moveFromAlgebraic){
        possibleMovesFromSquare.add(move);
      }
    }

    List<Point> toPositions = [];
    for(Move move in possibleMovesFromSquare){
      String toNumerical = move.toAlgebraic.replaceAll("a", "1").replaceAll("b", "2").replaceAll("c", "3").replaceAll("d", "4").replaceAll("e", "5").replaceAll("f", "6").replaceAll("g", "7").replaceAll("h", "8");
      int toX = int.parse(toNumerical[0]);
      int toY = int.parse(toNumerical[1]);
      toPositions.add(Point(toX, toY));
    }

    for(Point toPosition in toPositions){
      int x = toPosition.x.toInt();
      int y = 9 - toPosition.y.toInt();
      if(!isWhite){
        x = 9 - x;
        y = 9 - y;
      }
      canvas.drawCircle(Offset((squareSize*x) - (squareSize/2), (squareSize*y) - (squareSize/2)), squareSize *0.25, paint);
    }

  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}