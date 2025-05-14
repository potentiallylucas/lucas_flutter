// game_state.dart
// Lucas Nguyen, chopped from dr koster's code
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "yak_state.dart";

// This is where you put whatever the game is about.

class GameState {
  bool iStart;
  bool myTurn;
  List<String> board;
  List<Widget> chat;
  List<String> letters; // all tiles
  List<String> xLetters; // these are the tiles in player hands
  List<String> yLetters;
  String selected; // whatever tile is currently selected for play
  List<String> xPile; // piles are the list of letters split in half
  List<String>
  yPile; // i initially tried to use a yc.say to remove tiles from both devices
  // but I kept getting debounce issues
  int xscore;
  int yscore;

  GameState(
    this.iStart,
    this.myTurn,
    this.board,
    this.chat,
    this.letters,
    this.xLetters,
    this.yLetters,
    this.selected,
    this.xPile,
    this.yPile,
    this.xscore,
    this.yscore,
  );
}

class GameCubit extends Cubit<GameState> {
  static final String d = ".";
  static final List<String> allLetters = [
    'a',
    'a',
    'a',
    'a',
    'a',
    'a',
    'a',
    'a',
    'a',
    'b',
    'b',
    'c',
    'c',
    'd',
    'd',
    'd',
    'd',
    'e',
    'e',
    'e',
    'e',
    'e',
    'e',
    'e',
    'e',
    'e',
    'e',
    'e',
    'e',
    'f',
    'f',
    'g',
    'g',
    'g',
    'h',
    'h',
    'i',
    'i',
    'i',
    'i',
    'i',
    'i',
    'i',
    'i',
    'i',
    'j',
    'k',
    'l',
    'l',
    'l',
    'l',
    'm',
    'm',
    'n',
    'n',
    'n',
    'n',
    'n',
    'n',
    'o',
    'o',
    'o',
    'o',
    'o',
    'o',
    'o',
    'o',
    'p',
    'p',
    'q',
    'r',
    'r',
    'r',
    'r',
    'r',
    'r',
    's',
    's',
    's',
    's',
    't',
    't',
    't',
    't',
    't',
    't',
    'u',
    'u',
    'u',
    'u',
    'v',
    'v',
    'w',
    'w',
    'x',
    'y',
    'y',
    'z',
  ];
  GameCubit(bool myt) : super(_buildInitialState(myt)); // used for reset

  static GameState _buildInitialState(bool myt) {
    List<String> shuffled = List.from(allLetters)..shuffle();
    int half =
        shuffled.length ~/ 2; // shuffle all tiles and divide them among players
    List<String> xPile = shuffled.sublist(0, half);
    List<String> yPile = shuffled.sublist(half);

    return GameState(
      myt,
      myt,
      List.filled(225, d),
      [],
      List.from(allLetters),
      [],
      [],
      '',
      xPile,
      yPile,
      0,
      0,
    );
  }

  update(int where, String what) {
    state.board[where] = what;
    state.myTurn = !state.myTurn;
    emit(
      GameState(
        state.iStart,
        state.myTurn,
        state.board,
        state.chat,
        state.letters,
        state.xLetters,
        state.yLetters,
        '',
        state.xPile,
        state.yPile,
        state.xscore,
        state.yscore,
      ),
    );
  }

  void hands(String who, YakCubit yc, BuildContext context) {
    int count = who == 'x' ? state.xLetters.length : state.yLetters.length;
    if (state.letters.isEmpty) {
      // end game logic
      EndDialogue(context, "Out of letters... Restarting!");
      resetGame();
      return;
    }

    while (count < 7 && state.letters.isNotEmpty) {
      // adds tiles to player hands when they're below 7
      giveLetter(who, yc, context);
      print(state.letters.length);
      count++;
    }
  }

  void giveLetter(String who, YakCubit yc, BuildContext context) {
    // gives player tiles from their pile
    if (state.letters.isNotEmpty) {
      state.letters.shuffle();
      final updatedXLetters = List<String>.from(state.xLetters);
      final updatedYLetters = List<String>.from(state.yLetters);
      final updatedXPile = List<String>.from(state.xPile);
      final updatedYPile = List<String>.from(state.yPile);

      String letter = state.letters.removeAt(0);
      if (who == 'x') {
        updatedXLetters.add(letter);
        updatedXPile.remove(letter);
      } else {
        updatedYLetters.add(letter);
        updatedYPile.remove(letter);
      }
      print('$who : $letter');
      emit(
        GameState(
          state.iStart,
          state.myTurn,
          state.board,
          state.chat,
          List<String>.from(state.letters),
          updatedXLetters,
          updatedYLetters,
          '',
          updatedXPile,
          updatedYPile,
          state.xscore,
          state.yscore,
        ),
      );
    } else {
      print("No letters available!");
      resetGame();
      EndDialogue(context, 'Out of letters... Restarting!');
      yc.say('runout');
    }
  }

  void addChat(String msg) {
    final updatedChat = List<Widget>.from(state.chat)..add(Text(msg));
    emit(
      GameState(
        state.iStart,
        state.myTurn,
        state.board,
        updatedChat,
        state.letters,
        state.xLetters,
        state.yLetters,
        state.selected,
        state.xPile,
        state.yPile,
        state.xscore,
        state.yscore,
      ),
    );
  }

  String whoami() {
    return state.iStart ? "x" : "y";
  }

  play(String who, String tile, int where, BuildContext context) {
    state.board[where] = tile;
    state.myTurn = !state.myTurn;
    List<String> newXList = List.from(state.xLetters);
    List<String> newYList = List.from(state.yLetters);
    if (who == 'x') {
      newXList.remove(tile);
      state.xscore++;
    } else {
      newYList.remove(tile);
      state.yscore++;
    }

    emit(
      GameState(
        state.iStart,
        state.myTurn,
        state.board,
        state.chat,
        state.letters,
        newXList,
        newYList,
        '',
        state.xPile,
        state.yPile,
        state.xscore,
        state.yscore,
      ),
    );
  }

  void setSelected(String letter) {
    // wow global variables are hard
    String newLetter = letter;
    emit(
      GameState(
        state.iStart,
        state.myTurn,
        state.board,
        state.chat,
        state.letters,
        state.xLetters,
        state.yLetters,
        newLetter,
        state.xPile,
        state.yPile,
        state.xscore,
        state.yscore,
      ),
    );
  }

  void resign(BuildContext context) {
    // could honestly replace this with a "you resign!" because the socket handler
    String mark =
        state.myTurn == state.iStart
            ? "x"
            : "y"; // makes a popup that says opponent resigns
    EndDialogue(context, "$mark resigns!");
    resetGame();
  }

  void EndDialogue(BuildContext context, String msg) {
    // popup for any endgame alert
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

  void resetGame() {
    bool myt = state.myTurn;
    emit(_buildInitialState(myt));
    print("Game has been reset!");
  }

  // incoming messages are sent here for the game to do
  // whatever with.  in this case, "sq NUM" messages ..
  // we send the number to be played.
  void handle(String msg, BuildContext context) {
    List<String> parts = msg.split(" ");
    if (parts[0] == "sq") {
      int sqNum = int.parse(parts[1]);
      String tile = parts[2];
      String who = parts[3];
      play(who, tile, sqNum, context);
    } else if (parts[0] == "chat") {
      String chatMessage = msg.substring(5);
      final updatedChat = List<Widget>.from(state.chat)..add(Text(chatMessage));
      emit(
        GameState(
          state.iStart,
          state.myTurn,
          state.board,
          updatedChat,
          state.letters,
          state.xLetters,
          state.yLetters,
          '',
          state.xPile,
          state.yPile,
          state.xscore,
          state.yscore,
        ),
      );
    } else if (parts[0] == "resign") {
      resetGame();
      EndDialogue(context, "opponent resigns!");
    } else if (parts[0] == "runout") {
      EndDialogue(context, "Out of letters... Restarting!");
      resetGame();
    }
  }
}
