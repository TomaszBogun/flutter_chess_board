import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';
import '../chess/chess.dart' as c;
import '../flutter_chess_board.dart';

class StaticChessBoard extends StatefulWidget{
  /// An instance of [ChessBoardController] which holds the game and allows
  /// manipulating the board programmatically.
  final c.Chess chessGame;

  /// Size of chessboard
  final double? size;

  /// The color type of the board
  final BoardColor boardColor;

  final PlayerColor boardOrientation;

  final bool highlightLastMoveSquares;

  final dynamic highlightLastMoveSquaresColor;

  const StaticChessBoard({
    Key? key,
    required this.chessGame,
    this.size,
    this.boardColor = BoardColor.brown,
    this.boardOrientation = PlayerColor.white,
    this.highlightLastMoveSquares = true,
    required this.highlightLastMoveSquaresColor,
  }) : super(key: key);

  @override
  State<StaticChessBoard> createState() => _StaticChessboardState();
}


class _StaticChessboardState extends State<StaticChessBoard> {
  bool deferImagesLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    verifyRecommendedDeferredLoading();
  }

  void verifyRecommendedDeferredLoading() {
    if (!mounted) return;

    if (Scrollable.recommendDeferredLoadingForContext(context)) {
      deferImagesLoading = true;
      SchedulerBinding.instance.scheduleFrameCallback((_) {
        scheduleMicrotask(() => verifyRecommendedDeferredLoading());
      });
    } else {
      setState(() => deferImagesLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    FromToMove? squaresToHighlight = null;
    if(widget.highlightLastMoveSquares){
      squaresToHighlight = getSquaresToHighlight(widget.chessGame, widget.boardOrientation);
    }

    final boardImage = getBoardWidget(widget.boardColor, widget.boardOrientation == PlayerColor.white);


    final board = SizedBox.square(
      dimension: widget.size,
      child: Stack(
        alignment: Alignment.topLeft,
        clipBehavior: Clip.none,
        children: [
          // board background
          boardImage,

          // to & from square highlighter
          if(squaresToHighlight != null && widget.highlightLastMoveSquares) Container(
            width: widget.size!,
            height: widget.size,
            child: Stack(
              children: [
                Positioned(
                  left: squaresToHighlight.fromX * (widget.size!/8),
                  bottom: squaresToHighlight.fromY * (widget.size!/8),
                  child: Container(
                    color: widget.highlightLastMoveSquaresColor.withOpacity(0.45),
                    width: widget.size!/8,
                    height: widget.size!/8,
                  ),
                ),
                Positioned(
                  left: squaresToHighlight.toX * (widget.size!/8),
                  bottom: squaresToHighlight.toY * (widget.size!/8),
                  child: Container(
                    color: widget.highlightLastMoveSquaresColor.withOpacity(0.45),
                    width: widget.size!/8,
                    height: widget.size!/8,
                  ),
                ),
              ],
            ),
          ),

          // actual pieces
          if (!deferImagesLoading)
          // drawing pieces
            AspectRatio(
              aspectRatio: 1.0,
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8),
                itemBuilder: (context, index) {
                  var row = index ~/ 8;
                  var column = index % 8;
                  var boardRank = widget.boardOrientation == PlayerColor.black ? '${row + 1}' : '${(7 - row) + 1}';
                  var boardFile = widget.boardOrientation == PlayerColor.white ? '${files[column]}' : '${files[7 - column]}';
                  var squareName = '$boardFile$boardRank';
                  var piece = BoardPiece(squareName: squareName, game: widget.chessGame);
                  return piece;
                },
                itemCount: 64,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
              ),
            ),
        ],
      ),
    );
    return board;
  }
}


class BoardPieceForStaticChessBoard extends StatelessWidget {
  final String squareName;
  final c.Chess game;

  const BoardPieceForStaticChessBoard({
    Key? key,
    required this.squareName,
    required this.game,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    late Widget imageToDisplay;
    var square = game.get(squareName);

    if (game.get(squareName) == null) {
      return Container();
    }

    String piece = (square?.color == c.Color.WHITE ? 'W' : 'B') + (square?.type.toUpperCase() ?? 'P');

    switch (piece) {
      case "WP":
        imageToDisplay = Image.asset("images/white-pawn-64_x_64.png", package: 'flutter_chess_board');
        break;
      case "WR":
        imageToDisplay = Image.asset("images/white-rook-64_x_64.png", package: 'flutter_chess_board');
        break;
      case "WN":
        imageToDisplay = Image.asset("images/white-knight-64_x_64.png", package: 'flutter_chess_board');
        break;
      case "WB":
        imageToDisplay = Image.asset("images/white-bishop-64_x_64.png", package: 'flutter_chess_board');
        break;
      case "WQ":
        imageToDisplay = Image.asset("images/white-queen-64_x_64.png", package: 'flutter_chess_board');
        break;
      case "WK":
        imageToDisplay = Image.asset("images/white-king-64_x_64.png", package: 'flutter_chess_board');
        break;
      case "BP":
        imageToDisplay = Image.asset("images/black-pawn-64_x_64.png", package: 'flutter_chess_board');
        break;
      case "BR":
        imageToDisplay = Image.asset("images/black-rook-64_x_64.png", package: 'flutter_chess_board');
        break;
      case "BN":
        imageToDisplay = Image.asset("images/black-knight-64_x_64.png", package: 'flutter_chess_board');
        break;
      case "BB":
        imageToDisplay = Image.asset("images/black-bishop-64_x_64.png", package: 'flutter_chess_board');
        break;
      case "BQ":
        imageToDisplay = Image.asset("images/black-queen-64_x_64.png", package: 'flutter_chess_board');
        break;
      case "BK":
        imageToDisplay = Image.asset("images/black-king-64_x_64.png", package: 'flutter_chess_board');
        break;
      default:
        imageToDisplay = Container();
    }
    return imageToDisplay;
  }
}

void preloadBoardPieceForStaticChessBoards(BuildContext context) {
  const pieces = ['pawn', 'rook', 'knight', 'bishop', 'queen', 'king'];
  const colors = ['white', 'black'];
  for (var color in colors) {
    for (var piece in pieces) {
      final assetPath = "images/$color-$piece-64_x_64.png";
      precacheImage(AssetImage(assetPath, package: 'flutter_chess_board'), context);
    }
  }
}