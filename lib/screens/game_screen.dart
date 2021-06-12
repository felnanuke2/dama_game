import 'dart:async';

import 'package:dama_game/models/dama_model.dart';
import 'package:dama_game/screens/game_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  GameController _gameController = GameController();
  @override
  void initState() {
    _gameController.setDamasGamePosition();
    _gameController.validPositionAll();
    _gameController.startGame();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<GameController>.value(
      value: _gameController,
      builder: (context, child) {
        var model = Provider.of<GameController>(context, listen: true);
        return Scaffold(
          backgroundColor: Colors.blue,
          appBar: AppBar(
            title: Text(model.currentPlayer),
            centerTitle: true,
            actions: [
              Padding(
                padding: EdgeInsets.all(8),
                child: Center(
                  child: Text(
                    '${model.timer}',
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
                      model.scoreTop,
                      (index) => Container(
                            decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.brown),
                            width: 30,
                            child: Image.asset('assets/dama_icon.png'),
                          )),
                ),
              )),
              Text(
                model.player1Name,
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
                                    color: model.validPosition.contains(index)
                                        ? Colors.black
                                        : Colors.white,
                                    child: model.validPosition.contains(index)
                                        ? model.damasList
                                                .map((e) => e.position)
                                                .toList()
                                                .contains(index)
                                            ? InkWell(
                                                onTap: () => model.onPieceTap(index),
                                                child: CircleAvatar(
                                                    backgroundColor: model.topForcedMoves
                                                                .contains(index) ||
                                                            model.bottomForcedMoves.contains(index)
                                                        ? Colors.green
                                                        : model.damasList
                                                            .firstWhere((element) =>
                                                                element.position == index)
                                                            .color,
                                                    child: model.damasList
                                                            .map((e) => e.position)
                                                            .contains(index)
                                                        ? model.damasList
                                                                .firstWhere((element) =>
                                                                    element.position == index)
                                                                .dama
                                                            ? Padding(
                                                                padding: EdgeInsets.all(4),
                                                                child: Image.asset(
                                                                    'assets/queen-dama-negra.png'),
                                                              )
                                                            : Image.asset('assets/dama_icon.png')
                                                        : Text('data')),
                                              )
                                            : Container(
                                                child: Text(
                                                  '$index',
                                                  style:
                                                      TextStyle(color: Colors.white, fontSize: 28),
                                                ),
                                              )
                                        : null),
                                if (model.possibleMoves.contains(index) &&
                                    !model.damasList
                                        .map((e) => e.position)
                                        .toList()
                                        .contains(index))
                                  Center(
                                    child: InkWell(
                                      onTap: () => model.onTapToMovePiece(index),
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
                      model.scoreBottom,
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
      },
    );
  }
}
