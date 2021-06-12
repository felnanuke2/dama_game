import 'dart:async';

import 'package:flutter/material.dart';

class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  bool currentTurn = true;
  int timer = 30;
  bool awaitInteraction = false;
  String player1Name = 'Jogador 1';
  String player2Name = 'Jogador 2';
  String currentPlayer = '';
  var _completPlay = Completer<bool>();
  List<DamaPiece> damasList = [];
  List<int> possibleMoves = [];
  DamaPiece? selectedDama;
  List<int> initialPositionsTop = [1, 3, 5, 7, 8, 10, 12, 14, 17, 19, 21, 23];
  // List<int> initialPositionsBottom = [40, 42, 44, 46, 49, 51, 53, 55, 56, 58, 60, 62];
  List<int> initialPositionsBottom = [40, 28, 37, 46, 49, 51, 53, 55, 56, 58, 53];
  List<int> validPosition = [];
  int _scoreTop = 0;
  int _scoreBottom = 0;

  @override
  void initState() {
    _setDamasGamePosition();
    _validPosition();
    _startGame();
    super.initState();
  }

  _startGame() async {
    _completPlay.complete(true);
    currentPlayer = player1Name;
    while (!awaitInteraction) {
      await Future.delayed(Duration(seconds: 1));
      if (!_completPlay.isCompleted) {
        await _completPlay.future;
      }
      timer--;
      if (timer < 0) {
        _chageTurn();
      }
      setState(() {});
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(
        title: Text(currentPlayer),
        centerTitle: true,
        actions: [
          Padding(
            padding: EdgeInsets.all(8),
            child: Center(
              child: Text(
                '$timer',
                style: TextStyle(fontSize: 36),
              ),
            ),
          )
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
              child: Container(
            alignment: Alignment.topCenter,
            padding: EdgeInsets.all(8),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(
                  _scoreTop,
                  (index) => Container(
                        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.brown),
                        width: 30,
                        child: Image.asset('assets/dama_icon.png'),
                      )),
            ),
          )),
          Text(
            player1Name,
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          Center(
            child: Container(
              padding: EdgeInsets.all(1),
              decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 4)),
              child: AspectRatio(
                aspectRatio: 1 / 1,
                child: Container(
                  padding: EdgeInsets.all(0),
                  decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 4)),
                  child: GridView.count(
                      physics: NeverScrollableScrollPhysics(),
                      crossAxisCount: 8,
                      childAspectRatio: 1 / 1,
                      children: List.generate(64, (index) {
                        return Stack(
                          children: [
                            Container(
                                padding: EdgeInsets.all(8),
                                color: validPosition.contains(index) ? Colors.black : Colors.white,
                                child: validPosition.contains(index)
                                    ? damasList.map((e) => e.position).toList().contains(index)
                                        ? InkWell(
                                            onTap: () {
                                              final dama = damasList.firstWhere(
                                                  (element) => element.position == index);
                                              if (dama.startOnTop != currentTurn) return;
                                              selectedDama = dama;
                                              setState(() {
                                                _showPossiblesMoves(
                                                  dama,
                                                );
                                              });
                                            },
                                            child: CircleAvatar(
                                              backgroundColor: damasList
                                                  .firstWhere(
                                                      (element) => element.position == index)
                                                  .color,
                                              child: Text('$index'),
                                            ),
                                          )
                                        : Container(
                                            child: Text(
                                              '$index',
                                              style: TextStyle(color: Colors.white, fontSize: 28),
                                            ),
                                          )
                                    : null),
                            if (possibleMoves.contains(index) &&
                                !damasList.map((e) => e.position).toList().contains(index))
                              Center(
                                child: InkWell(
                                  onTap: () async {
                                    if (!_completPlay.isCompleted) {
                                      _completPlay.complete(true);
                                    }
                                    _movimentDama(index);
                                    possibleMoves = [];
                                    setState(() {});
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
                                        setState(() {});
                                      }
                                    }
                                    if (possibleMoves.isNotEmpty) {
                                    } else {
                                      _chageTurn();
                                      //todo next Player turn set
                                      selectedDama = null;
                                    }

                                    setState(() {});
                                  },
                                  child: Container(
                                    width: 20,
                                    child: CircleAvatar(
                                      backgroundColor: Colors.green,
                                    ),
                                  ),
                                ),
                              )
                          ],
                        );
                      })),
                ),
              ),
            ),
          ),
          Text(
            'Jogador 2',
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          Expanded(
              child: Container(
            alignment: Alignment.bottomCenter,
            padding: EdgeInsets.all(8),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(
                  _scoreBottom,
                  (index) => Container(
                        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                        width: 30,
                        child: Image.asset('assets/dama_icon.png'),
                      )),
            ),
          )),
        ],
      ),
    );
  }

  _setDamasGamePosition() {
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

  List<int> topForcedMoves = [];
  List<int> bottomForcedMoves = [];
  _showFocedMoves() {
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
  }

  _validPosition() {
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
    print('called remove');

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
