// draws saved moves
import 'dart:math';
import 'package:flutter/cupertino.dart';

class NextMoveDrawer extends CustomPainter{
  List<String> nextMovesArrowsNumerical;
  bool isWhite;
  Color color;
  NextMoveDrawer({required this.nextMovesArrowsNumerical, required this.isWhite, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    double sizeMultiplier = 1;
    Paint paint = Paint()..strokeWidth=size.width/(50*(1/sizeMultiplier))..color=color;
    for (var nextMoveArrowNumerical in nextMovesArrowsNumerical){
      drawArrow(canvas, size, nextMoveArrowNumerical, color, isWhite, paint, sizeMultiplier);
    }
  }


  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}


void drawArrow(Canvas canvas, Size size, String nextMoveArrowNumerical, Color color, bool isWhite, Paint paint, double sizeMultiplier){
  double x1 = double.parse(nextMoveArrowNumerical.substring(0,1));
  double y1 = double.parse(nextMoveArrowNumerical.substring(1,2));
  double x2 = double.parse(nextMoveArrowNumerical.substring(2,3));
  double y2 = double.parse(nextMoveArrowNumerical.substring(3,4));

  double xOffset = 0;
  double yOffset = 0;
  if(x1 < x2){
    xOffset = size.width/24;
  }else if(x1 > x2){
    xOffset = -size.width/24;
  }
  if(y1 < y2){
    yOffset = size.width/24;
  }else if(y1 > y2){
    yOffset = -size.width/24;
  }

  if(isWhite){
    x1 = ((x1)*size.width/8) - (size.width/16) + xOffset;
    y1 = ((8-y1)*size.width/8) + (size.width/16) - yOffset;
    x2 = ((x2)*size.width/8) - (size.width/16);
    y2 = ((8-y2)*size.width/8) + (size.width/16);
  }else{
    x1 = ((8-x1)*size.width/8) + (size.width/16) - xOffset;
    y1 = (y1*size.width/8) - (size.width/16) + yOffset;
    x2 = ((8-x2)*size.width/8) + (size.width/16);
    y2 = (y2*size.width/8) - (size.width/16);
  }

  double triangleSizeDivisor = 32;

  // Adjust line endpoint to accommodate the triangle so any opaque colours don't overlap
  double triangleLength = size.width / triangleSizeDivisor * sizeMultiplier * 0.8; // Length to subtract for the triangle
  double dx = x2 - x1;
  double dy = y2 - y1;
  double distance = sqrt(dx * dx + dy * dy);
  double adjustX = (dx / distance) * triangleLength;
  double adjustY = (dy / distance) * triangleLength;

  canvas.drawLine(Offset(x1, y1), Offset(x2 - adjustX, y2 - adjustY), paint);

  double angle = atan2(y2-y1, x2-x1) + (pi/2);
  drawTriangle(canvas, size.width/triangleSizeDivisor, angle, Offset(x2, y2), paint, sizeMultiplier);
}

void drawTriangle(Canvas canvas, double size, double angle, Offset position, Paint paint, double sizeMultiplier) {
  Path path = Path();
  path.moveTo(position.dx, position.dy - (size * sizeMultiplier) * 0.8);
  path.lineTo(position.dx - (size * sizeMultiplier) , position.dy + (size * sizeMultiplier) * 0.8);
  path.lineTo(position.dx + (size * sizeMultiplier) , position.dy + (size * sizeMultiplier) * 0.8);
  path.close();

  final matrix4 = Matrix4.identity()..translate(position.dx, position.dy)..rotateZ(angle)..translate(-position.dx, -position.dy);
  path = path.transform(matrix4.storage);

  canvas.drawPath(path, paint);
}