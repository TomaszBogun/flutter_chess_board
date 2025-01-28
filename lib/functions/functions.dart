import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chess_board/flutter_chess_board.dart';
import 'package:tuple/tuple.dart';
import '../chess/chess.dart';
import '../drawers/ChessBoardDrawer.dart';

// converts raw coordinates of the board where the user tapped on to board square coordinates
Point getTapPositionOnBoard(Point tapPosition, double squareSize){
  int tapSquareXInt = ((tapPosition.x ~/ squareSize)+1);
  int tapSquareYInt = (8-((tapPosition.y ~/ squareSize)));
  return Point(tapSquareXInt, tapSquareYInt);
}

// checks if a move going from sourceSquareName to sourceSquareName can be a promotion move
bool promotionMoveIsPossible(ChessBoardController chessController, String sourceSquareName, String destinationSquareName){
  List<Move> moves = chessController.game.generate_moves();
  Map moveToCheck = {"from": sourceSquareName, "to": destinationSquareName, "promotion": "q"};

  for (var i = 0; i < moves.length; i++) {
    if (moveToCheck['from'] == moves[i].fromAlgebraic && moveToCheck['to'] == moves[i].toAlgebraic && moves[i].promotion != null) {
      return true;
    }
  }
  return false;
}

Widget getBoardWidget(BoardColor color) {
  var lightSquareColor = boardColorToHexColor[color]![0];
  var darkSquareColor = boardColorToHexColor[color]![1];

  return Expanded(
    child: CustomPaint(
      painter: ChessBoardDrawer(
        lightSquareColor: lightSquareColor,
        darkSquareColor: darkSquareColor,
      ),
    ),
  );
}

// gets from and to square of the last move
Tuple2<Point, Point>? getSquaresToHighlight(Chess chessGame, PlayerColor boardOrientation){
  var history = chessGame.getHistory({"verbose": true});
  if (history.isEmpty){
    return null;
  }
  var lastMove = history.last;

  String from = lastMove["from"].replaceAll("a","1").replaceAll("b","2").replaceAll("c","3").replaceAll("d","4").replaceAll("e","5").replaceAll("f","6").replaceAll("g","7").replaceAll("h","8");
  String to = lastMove["to"].replaceAll("a","1").replaceAll("b","2").replaceAll("c","3").replaceAll("d","4").replaceAll("e","5").replaceAll("f","6").replaceAll("g","7").replaceAll("h","8");
  Point sourceSquare = Point(int.parse(from.substring(0, 1))-1, int.parse(from.substring(1, 2)) - 1);
  Point destinationSquare = Point(int.parse(to.substring(0, 1))-1, int.parse(to.substring(1, 2)) - 1);

  if(boardOrientation == PlayerColor.black){
    sourceSquare = Point(7-sourceSquare.x, 7-sourceSquare.y);
    destinationSquare = Point(7-destinationSquare.x, 7-destinationSquare.y);
  }
  return Tuple2(sourceSquare, destinationSquare);
}

// lets user choose which piece to promot to
Future<String?> promotionDialog(BuildContext context) async {
  return showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return new AlertDialog(
        title: new Text("Choose promotion"),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            InkWell(
              child: WhiteQueen(),
              onTap: () {
                Navigator.of(context).pop("q");
              },
            ),
            InkWell(
              child: WhiteRook(),
              onTap: () {
                Navigator.of(context).pop("r");
              },
            ),
            InkWell(
              child: WhiteBishop(),
              onTap: () {
                Navigator.of(context).pop("b");
              },
            ),
            InkWell(
              child: WhiteKnight(),
              onTap: () {
                Navigator.of(context).pop("n");
              },
            ),
          ],
        ),
      );
    },
  ).then((value) {
    return value;
  });
}
