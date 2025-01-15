import 'dart:math';

Point getTapPositionOnBoard(Point tapPosition, double squareSize){
  int tapSquareXInt = ((tapPosition.x ~/ squareSize)+1);
  int tapSquareYInt = (8-((tapPosition.y ~/ squareSize)));
  return Point(tapSquareXInt, tapSquareYInt);
}