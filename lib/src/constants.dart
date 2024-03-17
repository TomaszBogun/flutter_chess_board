import 'dart:ui';

const files = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'];

/// Enum which stores board types
enum BoardColor {
  brown,
  darkBrown,
  orange,
  green,
}

Map<BoardColor, List<Color>> boardColorToHexColor = {
  BoardColor.brown: [Color(0xfff0dab5), Color(0xffb58763)],
  BoardColor.darkBrown: [Color(0xffefdebf), Color(0xff7f6c63)],
  BoardColor.green: [Color(0xfff0dab5), Color(0xffb58763)],
  BoardColor.orange: [Color(0xffefdebf), Color(0xffcd733a)],
};

enum PlayerColor {
  white,
  black,
}

enum BoardPieceType { Pawn, Rook, Knight, Bishop, Queen, King }

RegExp squareRegex = RegExp("^[A-H|a-h][1-8]\$");
