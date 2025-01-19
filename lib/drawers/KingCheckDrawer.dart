import 'package:flutter/cupertino.dart';

class KingCheckDrawer extends CustomPainter{
  String checkSquareNumerical;
  bool isWhite;
  Color color;
  KingCheckDrawer({required this.checkSquareNumerical, required this.isWhite, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..strokeWidth=size.width/50..color=color;
      double positionX = double.parse(checkSquareNumerical.substring(0,1));
      double positionY = 8-double.parse(checkSquareNumerical.substring(1,2));
      double squareSize = size.width/8;

      double centerX = (positionX * squareSize) - (squareSize/2);
      double centerY = (positionY * squareSize) + (squareSize/2);
      double left = centerX - (squareSize/2);
      double right = centerX + (squareSize/2);
      double bottom = centerY + (squareSize/2);
      double top = centerY - (squareSize/2);

      if(!isWhite){
        left = size.width - left;
        right = size.width - right;
        bottom = size.width - bottom;
        top = size.width - top;
      }

      canvas.drawRect(Rect.fromLTRB(left, right, top, bottom), paint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}