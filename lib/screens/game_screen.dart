import 'package:flutter/material.dart';

class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  @override
  void initState() {
    _setDamasGamePosition();
    _validPosition();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
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
                                color: validPosition.contains(index) ? Colors.black : null,
                                child: validPosition.contains(index)
                                    ? damasList.map((e) => e.position).toList().contains(index)
                                        ? InkWell(
                                            onTap: () {
                                              final dama = damasList.firstWhere(
                                                  (element) => element.position == index);
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
                                        : null
                                    : null),
                            if (possibleMoves.contains(index) &&
                                !damasList.map((e) => e.position).toList().contains(index))
                              Center(
                                child: InkWell(
                                  onTap: () {
                                    _movimentDama(index);
                                    setState(() {});
                                    _haveMoremoviments(selectedDama!);
                                    if (possibleMoves.isNotEmpty) {
                                    } else {
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
        ],
      ),
    );
  }

  List<DamaPiece> damasList = [];
  List<int> possibleMoves = [];
  DamaPiece? selectedDama;

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

  List<int> initialPositionsTop = [1, 3, 5, 7, 8, 10, 12, 14, 17, 19, 21, 23];
  List<int> initialPositionsBottom = [40, 42, 44, 46, 49, 51, 53, 55, 56, 58, 60, 62];

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

  List<int> validPosition = [];
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

  void _movimentDama(int index) {
    final distance = selectedDama!.position! - index;

    switch (distance) {
      case 18:
        {
          damasList.removeWhere((element) => element.position == selectedDama!.position! - 9);
          break;
        }
      case -18:
        {
          damasList.removeWhere((element) => element.position == selectedDama!.position! + 9);
          break;
        }
      case 14:
        {
          damasList.removeWhere((element) => element.position == selectedDama!.position! - 7);
          break;
        }
      case -14:
        {
          damasList.removeWhere((element) => element.position == selectedDama!.position! + 7);
          break;
        }
      default:
    }
    selectedDama!.position = index;
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
              validPosition.contains(indexLess9 + 9)) {
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
