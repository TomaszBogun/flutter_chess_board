// draws hint square around piece when training
import 'package:flutter/cupertino.dart';

class HintSquareDrawer extends CustomPainter{
  List<String> hintSquarePositionsNumerical;
  bool isWhite;
  Color color;
  HintSquareDrawer({required this.hintSquarePositionsNumerical, required this.isWhite, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..strokeWidth=size.width/50..color=color;
    for (int i=0; i<hintSquarePositionsNumerical.length; i++){
      double positionX = double.parse(hintSquarePositionsNumerical[i].substring(0,1));
      double positionY = 8-double.parse(hintSquarePositionsNumerical[i].substring(1,2));
      double centerX; double centerY;
      double x1; double x2; double x3; double x4; double y1; double y2; double y3; double y4;
      double squareSize = size.width/8;

      centerX = (positionX * squareSize) - (squareSize/2);
      centerY = (positionY * squareSize) + (squareSize/2);
      x1 = centerX - (squareSize/2);
      x2 = centerX + (squareSize/2);
      x3 = x2;
      x4 = x1;
      y1 = centerY + (squareSize/2);
      y2 = y1;
      y3 = centerY - (squareSize/2);
      y4 = y3;

      if(!isWhite){
        x1 = size.width - x1;
        x2 = size.width - x2;
        x3 = size.width - x3;
        x4 = size.width - x4;
        y1 = size.width - y1;
        y2 = size.width - y2;
        y3 = size.width - y3;
        y4 = size.width - y4;
      }
      double width = size.width/100;
      isWhite ? canvas.drawLine(Offset(x1-width, y1), Offset(x2+width, y2), paint) : canvas.drawLine(Offset(x1+width, y1), Offset(x2-width, y2), paint);
      canvas.drawLine(Offset(x2, y2+width), Offset(x3, y3-width), paint);
      isWhite ? canvas.drawLine(Offset(x3+width, y3), Offset(x4-width, y4), paint) : canvas.drawLine(Offset(x3-width, y3), Offset(x4+width, y4), paint);
      canvas.drawLine(Offset(x4, y4-width), Offset(x1, y1+width), paint);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}