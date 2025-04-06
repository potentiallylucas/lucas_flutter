// game_state.dart
// Barrett Koster 2025

import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

// This is where you put whatever the game is about.

class GameState {
  bool iStart;
  bool myTurn;
  List<String> board;
  List<Widget> chat;
  GameState(this.iStart, this.myTurn, this.board, this.chat);
}

class GameCubit extends Cubit<GameState> {
  static final String d = ".";
  GameCubit(bool myt) : super(GameState(myt, myt, [d, d, d, d, d, d, d, d, d], []));

  update(int where, String what) {
    state.board[where] = what;
    state.myTurn = !state.myTurn;
    emit(GameState(state.iStart, state.myTurn, state.board, state.chat));
  }

  void addChat(String msg) {
  final updatedChat = List<Widget>.from(state.chat)..add(Text(msg));
  emit(GameState(state.iStart, state.myTurn, state.board, updatedChat));
}


  String whoami() {
    String mark = state.myTurn == state.iStart ? "x" : "o";
    return mark;
  }
  

  play(int where, BuildContext context) {
    String mark = state.myTurn == state.iStart ? "x" : "o";
    state.board[where] = mark;
    state.myTurn = !state.myTurn;
    emit(GameState(state.iStart, state.myTurn, state.board, state.chat));

    if (checkWin(mark)) {
      EndDialogue(context, "$mark wins!");
      resetGame();
    } else if (state.board.every((cell) => cell != d)) {
      EndDialogue(context, "It's a draw!");
      resetGame();
    }
  }

  void resign(BuildContext context) {
    String mark = state.myTurn == state.iStart ? "x" : "o";
    EndDialogue(context, "$mark resigns!");
    resetGame();
  }

  void EndDialogue(BuildContext context, String msg) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Game over!"),
          content: Text(msg),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Return to game"),
            ),
          ],
        );
      },
    );
  }

  bool checkWin(String mark) {
    List<List<int>> winPatterns = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6],
    ];

    for (List<int> pattern in winPatterns) {
      if (state.board[pattern[0]] == mark &&
          state.board[pattern[1]] == mark &&
          state.board[pattern[2]] == mark) {
        return true;
      }
    }
    return false;
  }

  void resetGame() {
    emit(GameState(state.iStart, state.iStart, [d, d, d, d, d, d, d, d, d], state.chat));
    print("Game has been reset!");
  }

  // incoming messages are sent here for the game to do
  // whatever with.  in this case, "sq NUM" messages ..
  // we send the number to be played.
  void handle(String msg, BuildContext context) {
    List<String> parts = msg.split(" ");
    if (parts[0] == "sq") {
      int sqNum = int.parse(parts[1]);
      play(sqNum, context);
    }
  }
}
