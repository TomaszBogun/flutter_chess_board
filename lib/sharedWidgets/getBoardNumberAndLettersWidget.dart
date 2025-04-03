import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import '../constants.dart';

Widget getBoardNumberAndLettersWidget(bool showBoardNumberAndLetters, PlayerColor boardOrientation, double size, BoardColor boardColor) {
  const double buffer = 2;
  const double sizeToTextRatio = 0.25;

  if (!showBoardNumberAndLetters) {
    return SizedBox();
  }

  final List<String> files = boardOrientation == PlayerColor.white ? ["a", "b", "c", "d", "e", "f", "g", "h"] : ["h", "g", "f", "e", "d", "c", "b", "a"];
  final List<String> ranks = boardOrientation == PlayerColor.white ? ["8", "7", "6", "5", "4", "3", "2", "1"] : ["1", "2", "3", "4", "5", "6", "7", "8"];

  final double squareSize = size / 8;
  final ui.Color textColor = boardColorToHexColor[boardColor]![0];
  final ui.Color altTextColor = boardColorToHexColor[boardColor]![1];

  return Container(
    width: size,
    height: size,
    child: Stack(
      children: [
        // Bottom letters (files)
        for (int i = 0; i < 8; i++)
          Positioned(
            left: (i * squareSize) + buffer,
            bottom: buffer,
            child: Text(
              files[i],
              style: TextStyle(
                color: i % 2 == 0 ? textColor : altTextColor,
                fontSize: squareSize * sizeToTextRatio,
              ),
            ),
          ),
        // Right numbers (ranks)
        for (int i = 0; i < 8; i++)
          Positioned(
            right: buffer,
            top: (i * squareSize) + buffer,
            child: Text(
              ranks[i],
              style: TextStyle(
                color: i % 2 == 0 ? textColor : altTextColor,
                fontSize: squareSize * sizeToTextRatio,
              ),
            ),
          ),
      ],
    ),
  );
}