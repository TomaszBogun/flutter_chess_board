import 'dart:ui';

const files = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'];

/// Enum which stores board types
enum BoardColor {
  brown,
  darkBrown,
  orange,
  green,
  blue,
  red,
  purple,
  gray,
  wood,
  marble,
  teal,
  pink,
  tan,
  cyan,
  yellow,
  aqua,
  ice,
  sand,
  forest,
  lavender,
}

Map<BoardColor, List<Color>> boardColorToHexColor = {
  BoardColor.brown: [Color(0xfff0dab5), Color(0xffb58763)],
  BoardColor.darkBrown: [Color(0xffefdebf), Color(0xff7f6c63)],
  BoardColor.green: [Color(0xfffefffe), Color(0xff01a6ad)],
  BoardColor.orange: [Color(0xffefdebf), Color(0xffcd733a)],
  BoardColor.blue: [Color(0xffddeeff), Color(0xff5471a6)],
  BoardColor.red: [Color(0xffffd4d4), Color(0xffaa3333)],
  BoardColor.purple: [Color(0xffe7e0ff), Color(0xff7a5cb0)],
  BoardColor.gray: [Color(0xfff8f8f8), Color(0xff888888)],
  BoardColor.wood: [Color(0xfff7e2be), Color(0xffa96e3f)],
  BoardColor.marble: [Color(0xfffcfaf6), Color(0xff545454)],
  BoardColor.teal: [Color(0xffe6ffff), Color(0xff009999)],
  BoardColor.pink: [Color(0xffffe6f0), Color(0xffd17b9d)],
  BoardColor.tan: [Color(0xfff6e8d6), Color(0xffb5987e)],
  BoardColor.cyan: [Color(0xffe0ffff), Color(0xff008b8b)],
  BoardColor.yellow: [Color(0xfffff9d5), Color(0xffd4a017)],
  BoardColor.aqua: [Color(0xffdff6f5), Color(0xff5a7d8b)],
  BoardColor.ice: [Color(0xffeaf8ff), Color(0xff9ac5e1)],
  BoardColor.sand: [Color(0xfffff3e0), Color(0xffc8a165)],
  BoardColor.forest: [Color(0xffe8f5e9), Color(0xff4caf50)],
  BoardColor.lavender: [Color(0xfff3e5f5), Color(0xff7e57c2)],
};

enum PlayerColor {
  white,
  black,
}

enum BoardPieceType { Pawn, Rook, Knight, Bishop, Queen, King }

RegExp squareRegex = RegExp("^[A-H|a-h][1-8]\$");
