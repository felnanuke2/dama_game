import 'package:flutter/material.dart';

class DamaPiece {
  int? position;
  final Color color;
  bool dama = false;
  final bool startOnTop;
  DamaPiece(
      {required this.position, required this.color, required this.dama, required this.startOnTop});
  bool isEnemy(DamaPiece damaPiece) {
    return damaPiece.startOnTop != this.startOnTop;
  }
}
