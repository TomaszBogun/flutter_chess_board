import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_chess_board/drawers/PossibleMovesDrawer.dart';
import 'package:flutter_chess_board/drawers/KingCheckDrawer.dart';
import 'package:tuple/tuple.dart';
import '../chess/chess.dart' hide State;
import '../drawers/ArrowDrawer.dart';
import '../drawers/HintSquareDrawer.dart';
import '../functions/functions.dart';
import '../sharedWidgets/getBoardNumberAndLettersWidget.dart';
import 'BoardPiece.dart';
import 'ChessBoardController.dart';
import '../constants.dart';
import "dart:ui" as ui;
import 'PieceMoveData.dart';

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
              SizedBox.square(
                dimension: widget.size,
                child: getBoardWidget(widget.boardColor),
              ),

              getBorderWidget(),

              // highlights from and to squares
              getHighlightLastSquaresWidget(),

              // used for highlighting the king square red if in check
              getKingCheckHighlighterWidget(),

              // showing board number and letters widget
              getBoardNumberAndLettersWidget(widget. showBoardNumberAndLetters, widget.boardOrientation, widget.size!, widget.boardColor),

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
        return Directionality(
          textDirection: TextDirection.ltr,
          child: GestureDetector(
            onTapDown: (TapDownDetails details){
              onBoardTap(details, game);
            },
            child: chessBoard,
          ),
        );
      },
    );
  }

  Widget getKingCheckHighlighterWidget(){
    bool isInCheck = false;

    try{
      isInCheck = widget.controller.game.in_check;
    }catch(e){}

    if(!isInCheck){
      return SizedBox();
    }

    bool whiteKingAttacked = widget.controller.game.king_attacked(ChessColor.WHITE);
    int king = widget.controller.game.kings[ChessColor.WHITE];
    if(!whiteKingAttacked){
      king = widget.controller.game.kings[ChessColor.BLACK];
    }
    String checkSquareNumerical = ((king%8)+1).toString() + (8-(king~/16)).toString();

    return Container(
      width: widget.size!,
      height: widget.size!,
      child: CustomPaint(
        foregroundPainter: KingCheckDrawer(checkSquareNumerical: checkSquareNumerical, isWhite: widget.boardOrientation == PlayerColor.white, color: ui.Color(0x6EFF0000)),
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
    Tuple2<Point, Point>? squaresToHighlight = null;
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
            left: squaresToHighlight.item1.x * (widget.size!/8),
            bottom: squaresToHighlight.item1.y * (widget.size!/8),
            child: Container(
              color: widget.mainColor.withOpacity(0.45),
              width: widget.size!/8,
              height: widget.size!/8,
            ),
          ),
          Positioned(
            left: squaresToHighlight.item2.x * (widget.size!/8),
            bottom: squaresToHighlight.item2.y * (widget.size!/8),
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

        var piece = BoardPiece(squareName: squareName, game: game);

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
            pieceColor: pieceOnSquare?.color ?? ChessColor.WHITE,
          ),
        )
            : Container();

        var dragTarget = DragTarget<PieceMoveData>(builder: (context, list, _) {
          return draggable;
        }, onWillAccept: (pieceMoveData) {
          return widget.enableUserMoves ? true : false;
        }, onAccept: (PieceMoveData pieceMoveData) async {
          ChessColor moveColor = game.turn; // A way to check if move occurred.
          if (promotionMoveIsPossible(widget.controller, pieceMoveData.squareName, squareName)) {
            var val = await promotionDialog(context);
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
      ChessColor moveColor = game.turn; // A way to check if move occurred.
      if (promotionMoveIsPossible(widget.controller, sourceSquareName, destinationSquareName)) {
        var val = await promotionDialog(context);
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
