import 'dart:async';
import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  _GameScreenState createState() => _GameScreenState();
}

enum Directions { up, down, left, right }

class _GameScreenState extends State<GameScreen> {
  static List<int> snakeCellNumbers = [45, 65, 85, 105, 125];
  static Random randomNumber = Random();
  int numberOfSquares = 760;
  int foodCellNumber = randomNumber.nextInt(700);
  var direction = Directions.down;
  var snakeMouthCellNumber = 0;
  bool isStartButtonEnabled = true;
  var animationDuration = 500;
  bool isStopped = false;

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.brown[900],
      appBar: null,
      body: Column(
        children: [
          Expanded(
            flex: 97000, //97%
            child: GestureDetector(
              onVerticalDragUpdate: (details) {
                if (direction != Directions.up && details.delta.dy > 0) {
                  direction = Directions.down;
                } else if (direction != Directions.down &&
                    details.delta.dy < 0) {
                  direction = Directions.up;
                }
              },
              onHorizontalDragUpdate: (details) {
                if (direction != Directions.left && details.delta.dx > 0) {
                  direction = Directions.right;
                } else if (direction != Directions.right &&
                    details.delta.dx < 0) {
                  direction = Directions.left;
                }
              },
              child: Container(
                child: GridView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: numberOfSquares,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 20),
                  itemBuilder: (BuildContext context, int index) {
                    if (snakeCellNumbers.contains(index)) {
                      return Center(
                        child: Container(
                          padding: EdgeInsets.all(2),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: Container(color: Colors.white),
                          ),
                        ),
                      );
                    } else if (index == foodCellNumber) {
                      return Container(
                        padding: EdgeInsets.all(2),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: Container(color: Colors.green),
                        ),
                      );
                    } else {
                      return Center(
                        child: Container(
                          padding: EdgeInsets.all(2),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: Container(color: Colors.brown[500]),
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
          ),
          _generateFooter()
        ],
      ),
    );
  }

  void _generateNewFood() {
    foodCellNumber = randomNumber.nextInt(700);
    while (snakeCellNumbers.contains(foodCellNumber)) {
      foodCellNumber = randomNumber.nextInt(700);
    }
  }

  void _startGame() {
    isStartButtonEnabled = false;
    snakeCellNumbers = [45, 65, 85, 105, 125];
    var duration = Duration(milliseconds: animationDuration);
    Timer.periodic(duration, (Timer timer) {
      _updateSnake(timer);
      if (_isGameOver()) {
        timer.cancel();
        _showGameOverScreen();
        isStartButtonEnabled = true;
      } else {}
    });
  }

  void changeSpeed(Timer timer) {
    isStartButtonEnabled = false;
    if (timer != null && timer.isActive) timer.cancel();
    animationDuration -= 10;
    timer = Timer.periodic(Duration(milliseconds: animationDuration), (timer) {
      setState(() {
        _updateSnake(timer);
        if (_isGameOver()) {
          timer.cancel();
          _showGameOverScreen();
          isStartButtonEnabled = true;
        } else {}
      });
    });
  }

  bool _isGameOver() {
    for (int i = 0; i < snakeCellNumbers.length; i++) {
      int count = 0;
      for (int j = 0; j < snakeCellNumbers.length; j++) {
        if (snakeCellNumbers[i] == snakeCellNumbers[j]) {
          count += 1;
        }
        if (count == 2) {
          direction = Directions.down;
          return true;
        }
      }
    }
    return false;
  }

  void _updateSnake(Timer timer) {
    snakeMouthCellNumber = snakeCellNumbers.last;
    setState(() {
      switch (direction) {
        case Directions.down:
          if (snakeMouthCellNumber > 740) {
            snakeCellNumbers.add(snakeMouthCellNumber + 20 - 760);
          } else {
            snakeCellNumbers.add(snakeMouthCellNumber + 20);
          }
          break;
        case Directions.up:
          if (snakeMouthCellNumber < 20) {
            snakeCellNumbers.add(snakeMouthCellNumber - 20 + 760);
          } else {
            snakeCellNumbers.add(snakeMouthCellNumber - 20);
          }
          break;
        case Directions.right:
          if ((snakeMouthCellNumber + 1) % 20 == 0) {
            snakeCellNumbers.add(snakeMouthCellNumber + 1 - 20);
          } else {
            snakeCellNumbers.add(snakeMouthCellNumber + 1);
          }
          break;
        case Directions.left:
          if (snakeMouthCellNumber % 20 == 0) {
            snakeCellNumbers.add(snakeMouthCellNumber - 1 + 20);
          } else {
            snakeCellNumbers.add(snakeMouthCellNumber - 1);
          }
          break;
        default:
      }
      if (snakeMouthCellNumber == foodCellNumber) {
        _generateNewFood();
        changeSpeed(timer);
      } else {
        snakeCellNumbers.removeAt(0);
      }
    });
  }

  void _showGameOverScreen() {
    showDialog(
        context: context,
        builder: (BuildContext buildContext) {
          return AlertDialog(
            title: Text('Game Over!'),
            content: Text(
                'Your score: ${(snakeCellNumbers.length * 10).toString()}'),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _startGame();
                  },
                  child: Text('Play Again'))
            ],
          );
        });
  }

  Expanded _generateFooter() {
    Size screenSize = MediaQuery.of(context).size;
    return Expanded(
      flex: 3000, //3%
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
        child: Row(
          children: [
            SizedBox(
              child: new IconButton(
                icon: new Icon(Icons.play_circle_filled),
                color: Colors.yellow,

                padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                constraints: BoxConstraints(),
                highlightColor: Colors.brown[200],
                onPressed: () {
                  isStartButtonEnabled ? _startGame() : null;
                },
              ),
            ),
            Spacer(),
            Text(
              '@Created by - Shaakuntal Apps',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
} //class
