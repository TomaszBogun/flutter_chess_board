import 'dart:math';
import 'package:chess_vectors_flutter/chess_vectors_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chess_board/drawers/PossibleMovesDrawer.dart';
import 'package:flutter_chess_board/drawers/KingCheckDrawer.dart';
import '../chess/chess.dart' hide State;
import '../drawers/ArrowDrawer.dart';
import '../drawers/HintSquareDrawer.dart';
import '../functions/functions.dart';
import 'chess_board_controller.dart';
import 'constants.dart';
import "dart:ui" as ui;

class ChessBoard extends StatefulWidget {
  /// An instance of [ChessBoardController] which holds the game and allows
  /// manipulating the board programmatically.
  final ChessBoardController controller;

  /// Size of chessboard
  final double? size;

  /// A boolean which checks if the user should be allowed to make moves
  final bool enableUserMoves;

  final bool showBoardNumberAndLetters;

  final PlayerColor boardOrientation;

  final bool highlightLastMoveSquares;

  // colors
  final BoardColor boardColor;
  final ui.Color mainColor; // used for next moves arrows, hint squares, solution arrows
  final ui.Color possibleMovesDotsColor; // used for drawing dots where pieces can go
  final ui.Color alreadyPlayedMovesArrowsColor; // used for drawing arrows that user already played while training
  final ui.Color borderColor; // used for drawing red or green border on incorrect or correct move while training

  // arrows and shapes
  final List<String> nextMovesArrowsNumerical;
  final List<String> alreadyPlayedMovesArrowsNumerical;
  final List<String> hintSquarePositionsNumerical;

  // functions
  final VoidCallback? onMove;
  final VoidCallback? beforeMove;

  ChessBoard({
    Key? key,
    required this.controller,
    this.size,
    this.showBoardNumberAndLetters = false,
    this.enableUserMoves = true,
    this.boardOrientation = PlayerColor.white,
    this.highlightLastMoveSquares = true,
    // colors
    this.boardColor = BoardColor.brown,
    this.mainColor = const ui.Color(0x00ffffff),
    this.possibleMovesDotsColor = const ui.Color(0x00ffffff),
    this.alreadyPlayedMovesArrowsColor = const ui.Color(0x00ffffff),
    this.borderColor = const ui.Color(0x00ffffff),
    // arrows and shapes
    this.nextMovesArrowsNumerical = const[],
    this.alreadyPlayedMovesArrowsNumerical = const[],
    this.hintSquarePositionsNumerical = const[],
    // functions
    this.onMove,
    this.beforeMove,
  }) : super(key: key);

  @override
  State<ChessBoard> createState() => _ChessBoardState();
}

class _ChessBoardState extends State<ChessBoard> {


  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Chess>(
      valueListenable: widget.controller,
      builder: (context, game, _) {
        var chessBoard = SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            children: [
              // actual board image
              getBoardWidget(widget.boardColor, widget.boardOrientation == PlayerColor.white),

              getBorderWidget(),

              // highlights from and to squares
              getHighlightLastSquaresWidget(),

              // used for highlighting the king square red if in check
              getKingCheckHighlighterWidget(),

              // showing board number and letters widget
              getBoardNumberAndLettersWidget(),

              // drawing pieces
              getPiecesWidget(game),

              // square hint highlighter
              getHintSquaresWidget(),

              // already played arrows
              getAlreadyPlayedMovesWidget(),

              // next moves arrows (or solution arrows)
              getNextMovesWidget(),

              // possible moves dots
              getPossibleMovesDotsWidget(),
            ],
          ),
        );

        // overlay widget to detect tap up and tap down
        return GestureDetector(
          onTapDown: (TapDownDetails details){
            onBoardTap(details, game);
          },
          child: chessBoard,
        );

      },
    );
  }

  Widget getKingCheckHighlighterWidget(){
    if(!widget.controller.game.in_check){
      return SizedBox();
    }

    bool whiteKingAttacked = widget.controller.game.king_attacked(Color.WHITE);
    int king = widget.controller.game.kings[Color.WHITE];
    if(!whiteKingAttacked){
      king = widget.controller.game.kings[Color.BLACK];
    }
    String checkSquareNumerical = ((king%8)+1).toString() + (8-(king~/16)).toString();

    return Container(
      width: widget.size!,
      height: widget.size!,
      child: CustomPaint(
        foregroundPainter: KingCheckDrawer(checkSquareNumerical: checkSquareNumerical, isWhite: widget.boardOrientation == PlayerColor.white, color: Colors.red.withValues(alpha: 110)),
      ),
    );
  }

  Widget getBorderWidget(){
    if(widget.borderColor.a == 255){
      return SizedBox();
    }

    double borderThicknessComparedToSingleChessBoardSquare = 0.1;
    double chessBoardSquareSize = widget.size!/8;
    double thicknessOfBorder = chessBoardSquareSize * borderThicknessComparedToSingleChessBoardSquare;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: widget.borderColor, width: thicknessOfBorder),
      ),
      width: widget.size!,
      height: widget.size!,
    );
  }

  Widget getHintSquaresWidget(){
    if(widget.hintSquarePositionsNumerical.isEmpty){
      return SizedBox();
    }

    return Container(
      width: widget.size!,
      height: widget.size!,
      child: CustomPaint(
        foregroundPainter: HintSquareDrawer(hintSquarePositionsNumerical: widget.hintSquarePositionsNumerical, isWhite: widget.boardOrientation == PlayerColor.white, color: widget.mainColor),
      ),
    );
  }

  Widget getHighlightLastSquaresWidget(){
    FromToMove? squaresToHighlight = null;
    if(widget.highlightLastMoveSquares){
      squaresToHighlight = getSquaresToHighlight(widget.controller.game, widget.boardOrientation);
    }

    if(squaresToHighlight == null || !widget.highlightLastMoveSquares){
      return SizedBox();
    }

    return Container(
      width: widget.size!,
      height: widget.size!,
      child: Stack(
        children: [
          Positioned(
            left: squaresToHighlight.fromX * (widget.size!/8),
            bottom: squaresToHighlight.fromY * (widget.size!/8),
            child: Container(
              color: widget.mainColor.withOpacity(0.45),
              width: widget.size!/8,
              height: widget.size!/8,
            ),
          ),
          Positioned(
            left: squaresToHighlight.toX * (widget.size!/8),
            bottom: squaresToHighlight.toY * (widget.size!/8),
            child: Container(
              color: widget.mainColor.withOpacity(0.45),
              width: widget.size!/8,
              height: widget.size!/8,
            ),
          ),
        ],
      ),
    );
  }

  Widget getBoardNumberAndLettersWidget() {
    const double buffer = 2;
    const double sizeToTextRatio = 0.25;

    if (!widget.showBoardNumberAndLetters) {
      return SizedBox();
    }

    final List<String> files = widget.boardOrientation == PlayerColor.white ? ["a", "b", "c", "d", "e", "f", "g", "h"] : ["h", "g", "f", "e", "d", "c", "b", "a"];
    final List<String> ranks = widget.boardOrientation == PlayerColor.white ? ["8", "7", "6", "5", "4", "3", "2", "1"] : ["1", "2", "3", "4", "5", "6", "7", "8"];

    final double squareSize = widget.size! / 8;
    final ui.Color textColor = boardColorToHexColor[widget.boardColor]![widget.boardOrientation == PlayerColor.white ? 0 : 1];
    final ui.Color altTextColor = boardColorToHexColor[widget.boardColor]![widget.boardOrientation == PlayerColor.white ? 1 : 0];

    return Container(
      width: widget.size!,
      height: widget.size!,
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

  Widget getPiecesWidget(Chess game){
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8),
      itemBuilder: (context, index) {
        var row = index ~/ 8;
        var column = index % 8;
        var boardRank = widget.boardOrientation == PlayerColor.black ? '${row + 1}' : '${(7 - row) + 1}';
        var boardFile = widget.boardOrientation == PlayerColor.white ? '${files[column]}' : '${files[7 - column]}';
        var squareName = '$boardFile$boardRank';
        var pieceOnSquare = game.get(squareName);

        var piece = BoardPiece(squareName: squareName, game: game, size: widget.size!,);

        var draggable = game.get(squareName) != null
            ? Draggable<PieceMoveData>(
          child: piece,
          feedback: SizedBox(
            width: widget.size! / 8,
            height: widget.size! / 8,
            child: piece,
          ),
          //feedbackOffset: Offset(widget.size! / 16, widget.size! / 16),
          childWhenDragging: SizedBox(),
          data: PieceMoveData(
            squareName: squareName,
            pieceType: pieceOnSquare?.type.toUpperCase() ?? 'P',
            pieceColor: pieceOnSquare?.color ?? Color.WHITE,
          ),
        )
            : Container();

        var dragTarget = DragTarget<PieceMoveData>(builder: (context, list, _) {
          return draggable;
        }, onWillAccept: (pieceMoveData) {
          return widget.enableUserMoves ? true : false;
        }, onAccept: (PieceMoveData pieceMoveData) async {
          Color moveColor = game.turn; // A way to check if move occurred.
          if (promotionMoveIsPossible(widget.controller, pieceMoveData.squareName, squareName)) {
            var val = await _promotionDialog(context);
            if (val == null) {
              return;
            }
            widget.beforeMove?.call();
            widget.controller.makeMoveWithPromotion(from: pieceMoveData.squareName, to: squareName, pieceToPromoteTo: val,);
          } else {
            widget.beforeMove?.call();
            widget.controller.makeMove(from: pieceMoveData.squareName, to: squareName,);
          }
          if (game.turn != moveColor) {
            widget.controller.pieceTapped = false;
            widget.onMove?.call();
          }
        });

        return dragTarget;
      },
      itemCount: 64,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
    );
  }

  Widget getAlreadyPlayedMovesWidget(){
    if(widget.alreadyPlayedMovesArrowsNumerical.isEmpty){
      return SizedBox();
    }

    return Container(
      width: widget.size!,
      height: widget.size!,
      child: CustomPaint(
        foregroundPainter: ArrowDrawer(arrowsNumerical: widget.alreadyPlayedMovesArrowsNumerical, isWhite: widget.boardOrientation == PlayerColor.white, color: widget.alreadyPlayedMovesArrowsColor),
      ),
    );
  }

  Widget getNextMovesWidget(){
    if(widget.nextMovesArrowsNumerical.isEmpty){
      return SizedBox();
    }

    return Container(
      width: widget.size!,
      height: widget.size!,
      child: CustomPaint(
        foregroundPainter: ArrowDrawer(arrowsNumerical: widget.nextMovesArrowsNumerical, isWhite: widget.boardOrientation == PlayerColor.white, color: widget.mainColor),
      ),
    );
  }

  Widget getPossibleMovesDotsWidget(){
    if(!widget.controller.pieceTapped) {
      return SizedBox();
    }

    return Container(
      width: widget.size!,
      height: widget.size!,
      child: CustomPaint(
        foregroundPainter: PossibleMovesDrawer(isWhite: widget.boardOrientation == PlayerColor.white, chessController: widget.controller, lastTappedPositionOnBoard: Point(widget.controller.lastTappedPositionOnBoard.x, widget.controller.lastTappedPositionOnBoard.y), color: widget.possibleMovesDotsColor),
      ),
    );
  }

  void onBoardTap(TapDownDetails details, Chess game) async{
    Point currentTapPositionOnBoard = getTapPositionOnBoard(Point(details.localPosition.dx, details.localPosition.dy), (widget.size!/8));
    bool tapPositionSame = currentTapPositionOnBoard.x.toInt() == widget.controller.lastTappedPositionOnBoard.x.toInt() && currentTapPositionOnBoard.y.toInt() == widget.controller.lastTappedPositionOnBoard.y.toInt();

    // tapped = false, same = false
    if(!widget.controller.pieceTapped && !tapPositionSame){
      widget.controller.pieceTapped = true;
      widget.controller.lastTappedPositionOnBoard = currentTapPositionOnBoard;
      setState(() {});
      return;
    }

    // tapped = false, same = true
    if(!widget.controller.pieceTapped && tapPositionSame){
      widget.controller.pieceTapped = true;
      setState(() {});
      return;
    }

    // tapped = true, same = false
    if(widget.controller.pieceTapped && !tapPositionSame){ // try move
      // only run if piece if piece is selected (possible moves dots visible)
      Point tapSource = Point(widget.controller.lastTappedPositionOnBoard.x, widget.controller.lastTappedPositionOnBoard.y);
      Point tapDestination = Point(currentTapPositionOnBoard.x, currentTapPositionOnBoard.y);
      if(widget.boardOrientation != PlayerColor.white){
        tapSource = Point(9 - tapSource.x, 9 - tapSource.y);
        tapDestination = Point(9 - tapDestination.x, 9 - tapDestination.y);
      }
      String sourceSquareName = '${files[tapSource.x.toInt()-1]}${tapSource.y}';
      String destinationSquareName = '${files[tapDestination.x.toInt()-1]}${tapDestination.y}';
      Color moveColor = game.turn; // A way to check if move occurred.
      if (promotionMoveIsPossible(widget.controller, sourceSquareName, destinationSquareName)) {
        var val = await _promotionDialog(context);
        if (val == null) {
          return;
        }
        widget.beforeMove?.call();
        widget.controller.makeMoveWithPromotion(from: sourceSquareName, to: destinationSquareName, pieceToPromoteTo: val,);
      } else {
        widget.beforeMove?.call();
        widget.controller.makeMove(from: sourceSquareName, to: destinationSquareName,);
      }
      if (game.turn != moveColor) {
        widget.controller.pieceTapped = false;
        widget.controller.lastTappedPositionOnBoard = Point(-1, -1);
        widget.onMove?.call();
      }else{
        widget.controller.pieceTapped = true;
        widget.controller.lastTappedPositionOnBoard = currentTapPositionOnBoard;
      }
      setState(() {});
      return;
    }

    // tapped = true, same = true
    if(widget.controller.pieceTapped && tapPositionSame){
      widget.controller.pieceTapped = false;
      setState(() {});
      return;
    }
  }
}

// gets from and to square of the last move
FromToMove? getSquaresToHighlight(Chess chessGame, PlayerColor boardOrientation){
  var history = chessGame.getHistory({"verbose": true});
  if (history.isEmpty){
    return null;
  }
  var lastMove = history.last;

  String from = lastMove["from"].replaceAll("a","1").replaceAll("b","2").replaceAll("c","3").replaceAll("d","4").replaceAll("e","5").replaceAll("f","6").replaceAll("g","7").replaceAll("h","8");
  String to = lastMove["to"].replaceAll("a","1").replaceAll("b","2").replaceAll("c","3").replaceAll("d","4").replaceAll("e","5").replaceAll("f","6").replaceAll("g","7").replaceAll("h","8");
  int fromX = int.parse(from.substring(0, 1)) - 1;
  int fromY = int.parse(from.substring(1, 2)) - 1;
  int toX = int.parse(to.substring(0, 1)) - 1;
  int toY = int.parse(to.substring(1, 2)) - 1;

  if(boardOrientation == PlayerColor.black){
    fromX = 7-fromX;
    fromY = 7-fromY;
    toX = 7-toX;
    toY = 7-toY;
  }
  return FromToMove(fromX, fromY, toX, toY);
}

int getImageSize(double? size){
  if(size == null){
    return 8;
  }
  if (size >= 128) {
    return 256;
  }
  if (size >= 64) {
    return 128;
  }
  if (size >= 32) {
    return 64;
  }
  if (size >= 16) {
    return 32;
  }
  if (size >= 8) {
    return 16;
  }
  return 8;
}

class BoardPiece extends StatelessWidget {
  final String squareName;
  final Chess game;
  final double? size;

  const BoardPiece({
    Key? key,
    required this.squareName,
    required this.game,
    this.size,

  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    late Widget imageToDisplay;
    var square = game.get(squareName);

    if (game.get(squareName) == null) {
      return Container();
    }


    int imageSize = getImageSize(size);
    String sizeString = imageSize.toString();

    String piece = (square?.color == Color.WHITE ? 'W' : 'B') +
        (square?.type.toUpperCase() ?? 'P');

    switch (piece) {
      case "WP":
        imageToDisplay = Image.asset("images/white-pawn-${sizeString}_x_${sizeString}.png", package: 'flutter_chess_board');
        break;
      case "WR":
        imageToDisplay = Image.asset("images/white-rook-${sizeString}_x_${sizeString}.png", package: 'flutter_chess_board');
        break;
      case "WN":
        imageToDisplay = Image.asset("images/white-knight-${sizeString}_x_${sizeString}.png", package: 'flutter_chess_board');
        break;
      case "WB":
        imageToDisplay = Image.asset("images/white-bishop-${sizeString}_x_${sizeString}.png", package: 'flutter_chess_board');
        break;
      case "WQ":
        imageToDisplay = Image.asset("images/white-queen-${sizeString}_x_${sizeString}.png", package: 'flutter_chess_board');
        break;
      case "WK":
        imageToDisplay = Image.asset("images/white-king-${sizeString}_x_${sizeString}.png", package: 'flutter_chess_board');
        break;
      case "BP":
        imageToDisplay = Image.asset("images/black-pawn-${sizeString}_x_${sizeString}.png", package: 'flutter_chess_board');
        break;
      case "BR":
        imageToDisplay = Image.asset("images/black-rook-${sizeString}_x_${sizeString}.png", package: 'flutter_chess_board');
        break;
      case "BN":
        imageToDisplay = Image.asset("images/black-knight-${sizeString}_x_${sizeString}.png", package: 'flutter_chess_board');
        break;
      case "BB":
        imageToDisplay = Image.asset("images/black-bishop-${sizeString}_x_${sizeString}.png", package: 'flutter_chess_board');
        break;
      case "BQ":
        imageToDisplay = Image.asset("images/black-queen-${sizeString}_x_${sizeString}.png", package: 'flutter_chess_board');
        break;
      case "BK":
        imageToDisplay = Image.asset("images/black-king-${sizeString}_x_${sizeString}.png", package: 'flutter_chess_board');
        break;
      default:
        imageToDisplay = Container();
    }

    return imageToDisplay;
  }
}

class PieceMoveData {
  final String squareName;
  final String pieceType;
  final Color pieceColor;

  PieceMoveData({
    required this.squareName,
    required this.pieceType,
    required this.pieceColor,
  });
}



Future<String?> _promotionDialog(BuildContext context) async {
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

// similar to move but we use this for highlighting squares
class FromToMove {
  final int fromX;
  final int fromY;
  final int toX;
  final int toY;
  const FromToMove(this.fromX, this.fromY, this.toX, this.toY);
}

Widget getBoardWidget(BoardColor color, bool isWhite){
  var lightSquareColor = boardColorToHexColor[color]![0];
  var darkSquareColor = boardColorToHexColor[color]![1];
  if(!isWhite){
    lightSquareColor = boardColorToHexColor[color]![1];
    darkSquareColor = boardColorToHexColor[color]![0];
  }

  return GridView.builder(
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 8,
    ),
    itemBuilder: (context, index) {
      final row = index ~/ 8; // Integer division
      final col = index % 8;
      final isLightSquare = (row + col) % 2 == 0;
      return Container(
        color: isLightSquare ? lightSquareColor : darkSquareColor,
      );
    },
    itemCount: 64,
  );

}
