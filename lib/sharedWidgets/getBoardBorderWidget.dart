import 'package:flutter/cupertino.dart';

Widget getBoardBorderWidget(double boardSize, Color borderColor){
  if(borderColor.a == 255){
    return SizedBox();
  }

  double borderThicknessComparedToSingleChessBoardSquare = 0.1;
  double chessBoardSquareSize = boardSize/8;
  double thicknessOfBorder = chessBoardSquareSize * borderThicknessComparedToSingleChessBoardSquare;

  return Container(
    decoration: BoxDecoration(
      border: Border.all(color: borderColor, width: thicknessOfBorder),
    ),
    width: boardSize,
    height: boardSize,
  );
}