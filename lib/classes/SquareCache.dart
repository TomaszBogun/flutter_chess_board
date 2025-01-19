import 'package:flutter/cupertino.dart';

class SquareCache {
  static final Map<String, Widget> _cache = {};

  static Widget getSquare(bool isLightSquare, Color lightColor, Color darkColor) {
    final key = isLightSquare ? "light_$lightColor" : "dark_$darkColor";
    if (!_cache.containsKey(key)) {
      _cache[key] = Container(
        color: isLightSquare ? lightColor : darkColor,
      );
    }
    return _cache[key]!;
  }
}
