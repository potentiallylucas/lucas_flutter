// player.dart
// lucas nguyen, chopped from dr koster's code

import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

import "said_state.dart";
import "game_state.dart";
import "yak_state.dart";

/*
  A Player gets called for each of the ServerBase and the ClientBase.
  We establish the game state, usually different depending on 
  whether you are the starting player or not.  
  This establishes the Game and Said BLoC layers. 
*/
class Player extends StatelessWidget {
  final bool iStart;
  const Player(this.iStart, {super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<GameCubit>(
      create: (context) => GameCubit(iStart),
      child: BlocBuilder<GameCubit, GameState>(
        builder:
            (context, state) => BlocProvider<SaidCubit>(
              create: (context) => SaidCubit(),
              child: BlocBuilder<SaidCubit, SaidState>(
                builder:
                    (context, state) => Scaffold(
                      appBar: AppBar(title: Text("player")),
                      body: Player2(),
                    ),
              ),
            ),
      ),
    );
  }
}

// this layer initializes the communication.
// By this point, the socets exist in the YakState, but
// they have not yet been told to listen for messages.
class Player2 extends StatelessWidget {
  const Player2({super.key});

  @override
  Widget build(BuildContext context) {
    YakCubit yc = BlocProvider.of<YakCubit>(context);
    YakState ys = yc.state;
    SaidCubit sc = BlocProvider.of<SaidCubit>(context);

    if (ys.socket != null && !ys.listened) {
      sc.listen(context);
      yc.updateListen();
    }
    return Player3();
  }
}

// This is the actual presentation of the game.

class Player3 extends StatelessWidget {
  Player3({super.key});
  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    GameCubit gc = BlocProvider.of<GameCubit>(context);
    GameState gs = gc.state;
    bool isMyTurn = gs.myTurn;
    YakCubit yc = BlocProvider.of<YakCubit>(context);
    String whoAmI = gc.whoami();
    bool init = false;

    void send() {
      // used for chat
      final text = controller.text.trim();
      if (text.isNotEmpty) {
        gc.addChat('$whoAmI: $text');
        yc.say("chat $whoAmI: $text");
      }
    }

    if (!init) {
      // gives player tiles at start of turn once
      WidgetsBinding.instance.addPostFrameCallback((_) {
        gc.hands(whoAmI, yc, context);
        print('did hands');
      });
      init = true;
    }

    List<Widget> squares = List.generate(225, (index) => Sq(index));

    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(50.0),
            child: Column(
              children: [
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 15,
                    children: squares,
                  ), // game board
                ),
                Expanded(
                  child: BlocBuilder<GameCubit, GameState>(
                    builder: (context, state) {
                      return Row(
                        // player tiles
                        children:
                            whoAmI == 'x'
                                ? state.xLetters
                                    .map((str) => Tile(str, 1))
                                    .toList()
                                : state.yLetters
                                    .map((str) => Tile(str, 1))
                                    .toList(),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(100.0),
            child: Column(
              children: [
                BlocBuilder<GameCubit, GameState>(
                  //score
                  builder: (context, state) {
                    return Text(
                      'Scores:\nx: ${state.xscore}\ny: ${state.yscore}',
                    );
                  },
                ),
                ElevatedButton(
                  // resign button
                  onPressed: () {
                    if (isMyTurn) {
                      gc.resign(context);
                      yc.say('resign');
                    }
                  },
                  child: Text("Resign?"),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        // chat input
                        controller: controller,
                        onSubmitted: (_) => send(),
                        decoration: InputDecoration(
                          hintText: "Type a message...",
                        ),
                      ),
                    ),
                    IconButton(icon: Icon(Icons.send), onPressed: () => send()),
                  ],
                ),
                BlocBuilder<GameCubit, GameState>(
                  //chat box
                  builder: (context, state) {
                    return Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey, width: 5.0),
                      ),
                      padding: EdgeInsets.all(20),
                      child: SizedBox(
                        width: 600,
                        height: 200,
                        child: SingleChildScrollView(
                          child: Column(children: state.chat),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// the squares of the board are just buttons.  You press one
// to play it.  We should have control here over whether it
// is your turn or not (but this is not added yet).
class Sq extends StatelessWidget {
  final int sn;
  const Sq(this.sn, {super.key});

  @override
  Widget build(BuildContext context) {
    GameCubit gc = BlocProvider.of<GameCubit>(context);
    GameState gs = gc.state;
    // String mark = gs.iStart?"x":"y";

    YakCubit yc = BlocProvider.of<YakCubit>(context);
    bool isMyTurn = gs.myTurn;
    bool isEmpty = gs.board[sn] == GameCubit.d;
    String tile = gs.selected;
    String who = gc.whoami();

    return ElevatedButton(
      onPressed:
          (isMyTurn && isEmpty && tile != '')
              ? () {
                gc.play(who, tile, sn, context);
                yc.say("sq $sn $tile $who");
                gc.hands(who, yc, context);
                print('did hands');
              }
              : null,
      child: Text(gs.board[sn]),
    );
  }
}

class Tile extends StatelessWidget {
  // these are the tiles held in hand
  final int index;
  final String letter;
  const Tile(this.letter, this.index, {super.key});

  @override
  Widget build(BuildContext context) {
    GameCubit gc = BlocProvider.of<GameCubit>(context);
    GameState gs = gc.state;

    bool isMyTurn = gs.myTurn;
    bool isSelected = gs.selected == letter;

    return ElevatedButton(
      // sets selected letter and is amber when selected
      onPressed:
          (isMyTurn)
              ? () {
                gc.setSelected(letter);
              }
              : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.amber : null,
      ),
      child: Text(letter),
    );
  }
}
