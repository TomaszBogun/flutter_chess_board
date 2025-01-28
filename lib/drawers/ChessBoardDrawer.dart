import 'package:flutter/material.dart';

class ChessBoardDrawer extends CustomPainter {
  final Color lightSquareColor;
  final Color darkSquareColor;

  ChessBoardDrawer({
    required this.lightSquareColor,
    required this.darkSquareColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double squareSize = size.width / 8; // Each square is 1/8th of the board's width

    // Draw the large light-colored background
    final Paint lightSquarePaint = Paint()..color = lightSquareColor;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), lightSquarePaint);

    // Paint the dark squares
    final Paint darkSquarePaint = Paint()..color = darkSquareColor;

    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        // Only draw the dark squares
        if ((row + col) & 1 != 0) {
          final Rect squareRect = Rect.fromLTWH(
            col * squareSize, // X position
            row * squareSize, // Y position
            squareSize,       // Width
            squareSize,       // Height
          );
          canvas.drawRect(squareRect, darkSquarePaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false; // No need to repaint since the chessboard colors don't change
  }
}
