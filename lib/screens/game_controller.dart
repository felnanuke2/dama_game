import 'dart:async';

import 'package:dama_game/models/dama_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class GameController extends ChangeNotifier {
  bool currentTurn = true;
  int timer = 3;
  bool awaitInteraction = false;
  String player1Name = 'Jogador 1';
  String player2Name = 'Jogador 2';
  String currentPlayer = '';
  var _completPlay = Completer<bool>();
  List<DamaPiece> damasList = [];
  List<int> possibleMoves = [];
  DamaPiece? selectedDama;
  // List<int> initialPositionsTop = [1, 3, 5, 7, 8, 10, 12, 14, 17, 19, 21, 23];
  List<int> initialPositionsTop = [1, 3, 5, 7, 8, 10, 12, 14, 17, 19, 23];
  // List<int> initialPositionsBottom = [40, 42, 44, 46, 49, 51, 53, 55, 56, 58, 60, 62];
  List<int> initialPositionsBottom = [40, 21, 37, 46, 35, 51, 53, 55, 49, 58, 53];
  List<int> validPosition = [];
  int _scoreTop = 0;
  int get scoreTop => _scoreTop;
  int _scoreBottom = 0;
  int get scoreBottom => _scoreBottom;
  List<int> topForcedMoves = [];
  List<int> bottomForcedMoves = [];
  var damaPositionsBottom = [56, 58, 60, 62];
  var damaPositionsTop = [1, 3, 5, 7];

  onPieceTap(int index) {
    if (!_completPlay.isCompleted) return;
    if (currentTurn) {
      if (topForcedMoves.isNotEmpty) {
        if (!topForcedMoves.contains(index)) return;
      }
    } else {
      if (bottomForcedMoves.isNotEmpty) {
        if (!bottomForcedMoves.contains(index)) {
          return;
        }
      }
    }
    final dama = damasList.firstWhere((element) => element.position == index);
    if (dama.startOnTop != currentTurn) return;
    selectedDama = dama;
    _showPossiblesMoves(
      dama,
    );
    notifyListeners();
  }

  onTapToMovePiece(int index) async {
    if (!_completPlay.isCompleted) {
      _completPlay.complete(true);
    }
    _movimentDama(index);
    possibleMoves = [];
    notifyListeners();
    await damaRemoveLoop();
    if (possibleMoves.isNotEmpty) {
    } else {
      _chageTurn();
      //todo next Player turn set
      selectedDama = null;
    }

    notifyListeners();
  }

  startGame() async {
    _completPlay.complete(true);
    currentPlayer = player1Name;
    _showForcedMoves();
    while (!awaitInteraction) {
      await Future.delayed(Duration(seconds: 1));
      if (!_completPlay.isCompleted) {
        await _completPlay.future;
      }
      timer--;
      if (timer < 0) {
        if (currentTurn) {
          if (topForcedMoves.isNotEmpty) {
            var dama = damasList.firstWhere((element) => element.position == topForcedMoves.first);
            selectedDama = dama;
            topForcedMoves.clear();
            await damaRemoveLoop();
          }
        } else {
          if (bottomForcedMoves.isNotEmpty) {
            var dama =
                damasList.firstWhere((element) => element.position == bottomForcedMoves.first);
            bottomForcedMoves.clear();
            selectedDama = dama;
            await damaRemoveLoop();
          }
        }
        _chageTurn();
      }
      notifyListeners();
    }
  }

  _chageTurn() {
    timer = 30;
    currentTurn = !currentTurn;
    if (currentPlayer == player1Name) {
      currentPlayer = player2Name;
    } else {
      currentPlayer = player1Name;
    }
    possibleMoves = [];
    _showForcedMoves();
  }

  damaRemoveLoop() async {
    if (selectedDama != null) {
      _haveMoremoviments(selectedDama!);
      while (possibleMoves.isNotEmpty) {
        await Future.delayed(Duration(milliseconds: 400));
        if (possibleMoves.length == 1) {
          _movimentDama(possibleMoves.first);
          possibleMoves = [];
          if (selectedDama != null) {
            _haveMoremoviments(selectedDama!);
          } else {
            break;
          }
        } else if (possibleMoves.isNotEmpty) {
          _completPlay = Completer<bool>();
          await _completPlay.future;
        }
        notifyListeners();
      }
    }
    return;
  }

  setDamasGamePosition() {
    List.generate(64, (index) {
      if (initialPositionsTop.contains(index)) {
        damasList
            .add(DamaPiece(position: index, color: Colors.white, dama: false, startOnTop: true));
      } else if (initialPositionsBottom.contains(index)) {
        damasList
            .add(DamaPiece(position: index, color: Colors.brown, dama: false, startOnTop: false));
      }
    });
  }

  _showForcedMoves() {
    topForcedMoves.clear();
    bottomForcedMoves.clear();

    damasList.where((element) => element.startOnTop == currentTurn).toList().forEach((element) {
      possibleMoves.clear();
      _haveMoremoviments(element);
      if (possibleMoves.isNotEmpty) {
        if (currentTurn) {
          topForcedMoves.add(element.position!);
        } else {
          bottomForcedMoves.add(element.position!);
        }
      }
    });

    possibleMoves.clear();
  }

  _showPossiblesMoves(DamaPiece damaPiece) {
    if (damaPiece.dama) {
      _possiblemovesOfDamasPiece(damaPiece);
    } else {
      _possibleMovesOfComunPieces(damaPiece);
    }
  }

  _possiblemovesOfDamasPiece(DamaPiece damaPiece) {
    if (damaPiece.dama) {
      int index7 = damaPiece.position!;
      int index9 = damaPiece.position!;
      bool up = false;
      while (true) {
        if (up) {
          index7 += 7;
          index9 += 9;
          if (index7 < 64 && validPosition.contains(index7)) {
            possibleMoves.add(index7);
          }
          if (index9 < 64 && validPosition.contains(index9)) {
            possibleMoves.add(index9);
          }
          if (index7 > 62) {
            break;
          }
        } else {
          index7 -= 7;
          index9 -= 9;
          if (validPosition.contains(index7) && index7 > 0) {
            possibleMoves.add(index7);
          }
          if (index9 > 0 && validPosition.contains(index9)) {
            possibleMoves.add(index9);
          }
          if (index7 < 0) {
            up = true;
          }
        }
      }
    }
  }

  _possibleMovesOfComunPieces(DamaPiece damaPiece) {
    possibleMoves.clear();
    List<int> occupedPositions = damasList.map((e) => e.position!).toList();
    bool canGet = true;
    var indexPlus9 = damaPiece.position! + 9;
    var indexLess9 = damaPiece.position! - 9;
    var indexPlus7 = damaPiece.position! + 7;
    var indexLess7 = damaPiece.position! - 7;
    while (canGet) {
      bool breakLoop = true;
      if (occupedPositions.contains(indexPlus7)) {
        var dama = _getDamaByPosition(indexPlus7);
        if (dama.isEnemy(damaPiece)) {
          if (!occupedPositions.contains(indexPlus7 + 7) &&
              validPosition.contains(indexPlus7 + 7)) {
            possibleMoves.add(indexPlus7 + 7);
            breakLoop = false;
            indexPlus7 += 7;
          }
        }
      } else {
        if (damaPiece.startOnTop && validPosition.contains(indexPlus7)) {
          possibleMoves.add(indexPlus7);
        }
      }
      if (occupedPositions.contains(indexLess7)) {
        var dama = _getDamaByPosition(indexLess7);
        if (dama.isEnemy(damaPiece)) {
          if (!occupedPositions.contains(indexLess7 - 7) &&
              validPosition.contains(indexLess7 - 7)) {
            possibleMoves.add(indexLess7 - 7);
            breakLoop = false;
            indexLess7 -= 7;
          }
        }
      } else {
        if (!damaPiece.startOnTop && validPosition.contains(indexLess7)) {
          possibleMoves.add(indexLess7);
        }
      }

      if (occupedPositions.contains(indexLess9)) {
        var dama = _getDamaByPosition(indexLess9);
        if (dama.isEnemy(damaPiece)) {
          if (!occupedPositions.contains(indexLess9 - 9) &&
              validPosition.contains(indexLess9 - 9)) {
            possibleMoves.add(indexLess9 - 9);
            breakLoop = false;
            indexLess9 -= 9;
          }
        }
      } else {
        if (!damaPiece.startOnTop && validPosition.contains(indexLess9)) {
          possibleMoves.add(indexLess9);
        }
      }
      if (occupedPositions.contains(indexPlus9)) {
        var dama = _getDamaByPosition(indexPlus9);
        if (dama.isEnemy(damaPiece)) {
          if (!occupedPositions.contains(indexPlus9 + 9) &&
              validPosition.contains(indexPlus9 + 9)) {
            possibleMoves.add(indexPlus9 + 9);
            breakLoop = false;
            indexPlus9 += 9;
          }
        }
      } else {
        if (damaPiece.startOnTop && validPosition.contains(indexPlus9)) {
          possibleMoves.add(indexPlus9);
        }
      }

      if (breakLoop == true) {
        canGet = false;
        break;
      }
    }
    possibleMoves.removeWhere((element) {
      var distance = damaPiece.position! - element;
      if (damaPiece.startOnTop) {
        if (topForcedMoves.isNotEmpty) {
          var abs = distance.abs();
          if ((abs != 14) && (abs != 18)) {
            return true;
          }
          return false;
        } else {
          return false;
        }
      } else {
        if (bottomForcedMoves.isNotEmpty) {
          var abs = distance.abs();
          if ((abs != 14) && (abs != 18)) {
            return true;
          }
          return false;
        } else {
          return false;
        }
      }
    });
  }

  validPositionAll() {
    int _counterRow = 0;
    int _counterColumn = 0;
    List.generate(64, (index) {
      _counterRow++;
      if (index % 8 == 0) {
        _counterColumn++;
        _counterRow = 0;
      }
      if (_counterRow % 2 == _counterColumn % 2) {
        validPosition.add(index);
      }
    });
  }

  /// move dama to selected position and remove a pice case is possible.
  /// case removed pices == 0 will set [selectedDama] to null;
  void _movimentDama(int index) {
    bool piecesGet = false;
    final distance = selectedDama!.position! - index;

    switch (distance) {
      case 18:
        {
          piecesGet = true;
          damasList.removeWhere((element) {
            bool remove = element.position == selectedDama!.position! - 9;
            if (remove == true) {
              if (element.startOnTop) {
                _scoreBottom++;
              } else {
                _scoreTop++;
              }
            }
            return remove;
          });
          break;
        }
      case -18:
        {
          piecesGet = true;
          damasList.removeWhere((element) {
            var remove = element.position == selectedDama!.position! + 9;
            if (remove == true) {
              if (element.startOnTop) {
                _scoreBottom++;
              } else {
                _scoreTop++;
              }
            }
            return remove;
          });
          break;
        }
      case 14:
        {
          piecesGet = true;
          damasList.removeWhere((element) {
            var remove = element.position == selectedDama!.position! - 7;
            if (remove == true) {
              if (element.startOnTop) {
                _scoreBottom++;
              } else {
                _scoreTop++;
              }
            }
            return remove;
          });
          break;
        }
      case -14:
        {
          piecesGet = true;
          damasList.removeWhere((element) {
            var remove = element.position == selectedDama!.position! + 7;
            if (remove == true) {
              if (element.startOnTop) {
                _scoreBottom++;
              } else {
                _scoreTop++;
              }
            }
            return remove;
          });
          break;
        }
      default:
    }
    selectedDama!.position = index;
    if (selectedDama!.startOnTop) {
      if (damaPositionsBottom.contains(index)) {
        selectedDama!.dama = true;
      }
    } else {
      if (damaPositionsTop.contains(index)) {
        selectedDama!.dama = true;
      }
    }
    if (!piecesGet) {
      selectedDama = null;
    }
  }

  void _haveMoremoviments(DamaPiece damaPiece) {
    possibleMoves.clear();
    List<int> occupedPositions = damasList.map((e) => e.position!).toList();
    bool canGet = true;
    var indexPlus9 = damaPiece.position! + 9;
    var indexLess9 = damaPiece.position! - 9;
    var indexPlus7 = damaPiece.position! + 7;
    var indexLess7 = damaPiece.position! - 7;
    while (canGet) {
      bool breakLoop = true;
      if (occupedPositions.contains(indexPlus7)) {
        var dama = _getDamaByPosition(indexPlus7);
        if (dama.isEnemy(damaPiece)) {
          if (!occupedPositions.contains(indexPlus7 + 7) &&
              validPosition.contains(indexPlus7 + 7)) {
            possibleMoves.add(indexPlus7 + 7);
            breakLoop = false;
            indexPlus7 += 7;
          }
        }
      }
      if (occupedPositions.contains(indexLess7)) {
        var dama = _getDamaByPosition(indexLess7);
        if (dama.isEnemy(damaPiece)) {
          if (!occupedPositions.contains(indexLess7 - 7) &&
              validPosition.contains(indexLess7 - 7)) {
            possibleMoves.add(indexLess7 - 7);
            breakLoop = false;
            indexLess7 -= 7;
          }
        }
      }

      if (occupedPositions.contains(indexLess9)) {
        var dama = _getDamaByPosition(indexLess9);
        if (dama.isEnemy(damaPiece)) {
          if (!occupedPositions.contains(indexLess9 - 9) &&
              validPosition.contains(indexLess9 - 9)) {
            possibleMoves.add(indexLess9 - 9);
            breakLoop = false;
            indexLess9 -= 9;
          }
        }
      }
      if (occupedPositions.contains(indexPlus9)) {
        var dama = _getDamaByPosition(indexPlus9);
        if (dama.isEnemy(damaPiece)) {
          if (!occupedPositions.contains(indexPlus9 + 9) &&
              validPosition.contains(indexPlus9 + 9)) {
            possibleMoves.add(indexPlus9 + 9);
            breakLoop = false;
            indexPlus9 += 9;
          }
        }
      }

      if (breakLoop == true) {
        canGet = false;
        break;
      }
      possibleMoves.removeWhere((element) => element > 62 || element < 1);
    }
  }

  DamaPiece _getDamaByPosition(int index) {
    return damasList.firstWhere(
      (element) => element.position == index,
    );
  }
}
