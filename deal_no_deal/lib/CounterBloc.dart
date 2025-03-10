import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:confetti/confetti.dart';
// Lucas Nguyen
// Missing some functionality:
// Does not use HydratedBloc, tried to implement but it fully broke the code and I couldn't get it figured out
// Detects keypresses for Deal, No Deal, and reset, but ran out of time before I could figure out how to get the 
// keypresses to select the suitcases

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Deal or No Deal',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => DealerOffer()),
          BlocProvider(create: (context) => FirstSuitcaseSelected()),
          BlocProvider(create: (context) => DealerIsOffering()),
          BlocProvider(create: (context) => GameOverState()),
        ],
        child: const MyHomePage(title: 'Deal or No Deal!'),
      ),
    );
  }

  void reset() {
    setState(() {});
  }
}

class FirstSuitcaseSelected extends Cubit<bool> {
  FirstSuitcaseSelected() : super(false);

  void toggle() {
    emit(!state);
  }
}

class Suitcase extends StatelessWidget {
  Suitcase({super.key, required this.value, required this.index});
  bool selected = false;
  bool highlight = false;
  final int value;
  final int index;
  final FocusNode focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    bool selectable = BlocProvider.of<inPlay>(context).state;
    void tap() {
      if (!BlocProvider.of<DealerIsOffering>(context).state) {
        if (BlocProvider.of<FirstSuitcaseSelected>(context).state) {
          if (selectable) {
            BlocProvider.of<inPlay>(context).toggle();
            selectable = false;
            BlocProvider.of<DealerOffer>(
              context,
            ).subtract(value.toDouble(), context);
            BlocProvider.of<DealerIsOffering>(context).toggle();
          }
        } else {
          BlocProvider.of<FirstSuitcaseSelected>(context).toggle();
          BlocProvider.of<Selected>(context).toggle();
          BlocProvider.of<inPlay>(context).toggle();
          selectable = false;
        }
      }
    }

    return GestureDetector(
      onTap: () {
        tap();
      },
      child: SizedBox(
        width: 150,
        height: 80,
        child: BlocBuilder<inPlay, bool>(
          builder: (context, show) {
            return Card(
              
              child: Center(
                child: Column(
                  children: [
                    BlocProvider.of<Selected>(context).state
                        ? show
                            ? Icon(Icons.luggage)
                            : Text('\$$value', style: TextStyle(fontSize: 30))
                        : Icon(Icons.luggage_outlined),
                    Text('Index: $index'),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void resetSuitcase(BuildContext context) {
    BlocProvider.of<inPlay>(context).emit(true);
    BlocProvider.of<Selected>(context).emit(true);
  }
}

class inPlay extends Cubit<bool> {
  inPlay() : super(true);

  void toggle() {
    emit(!state);
  }
}

class Selected extends Cubit<bool> {
  Selected() : super(true);

  void toggle() {
    emit(!state);
  }
}

class DealerIsOffering extends Cubit<bool> {
  DealerIsOffering() : super(false);

  void toggle() {
    emit(!state);
  }
}

class Boxes extends StatelessWidget {
  Boxes({super.key});

  List<Widget> boxes = [];
  List<int> boxValues = [
    1,
    5,
    10,
    100,
    1000,
    5000,
    10000,
    100000,
    500000,
    1000000,
  ];

  @override
  Widget build(BuildContext context) {
    boxValues.shuffle();
    final FocusNode focusNode = FocusNode();
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children:
          boxValues.asMap().entries.map((entry) {
            final index = entry.key;
            final value = entry.value;

            return MultiBlocProvider(
              providers: [
                BlocProvider(create: (context) => inPlay()),
                BlocProvider(create: (context) => Selected()),
              ],
              child: Suitcase(value: value, index: index),
            );
          }).toList(),
    );
  }
}

class DealerOffer extends Cubit<double> {
  DealerOffer() : super(145450.44);
  List<double> boxValues = [
    1,
    5,
    10,
    100,
    1000,
    5000,
    10000,
    100000,
    500000,
    1000000,
  ];

  void subtract(double i, BuildContext context) {
    boxValues.remove(i);
    if (boxValues.length > 1) {
      double expected = boxValues.reduce((x, y) => x + y);
      expected = expected / boxValues.length;
      emit(expected);
    } else {
      context.read<GameOverState>().toggle();
    }
  }

  void reset() {
    boxValues = [1, 5, 10, 100, 1000, 5000, 10000, 100000, 500000, 1000000];
  }
}

class GameOver extends StatelessWidget {
  const GameOver({super.key, required this.value});
  final double value;

  @override
  Widget build(BuildContext context) {
    final controller = ConfettiController(duration: const Duration(days: 3));
    final FocusNode focusNode = FocusNode();
    void restartGame() {
      (context.findAncestorStateOfType<MyAppState>())?.reset();
      BlocProvider.of<DealerOffer>(context).emit(145450.44);
      BlocProvider.of<DealerOffer>(context).reset();
      BlocProvider.of<FirstSuitcaseSelected>(context).emit(false);
      BlocProvider.of<DealerIsOffering>(context).emit(false);
      BlocProvider.of<GameOverState>(context).emit(false);
    }

    return KeyboardListener(
      focusNode: focusNode,
      autofocus: true,
      onKeyEvent: (event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.keyR) {
          restartGame();
        }
      },
      child: Stack(
        children: [
          Scaffold(
            appBar: AppBar(),
            body: Center(
              child: Column(
                children: [
                  Text(
                    'Game Over! You won: \$$value',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  ElevatedButton(
                    onPressed: restartGame,
                    child: Text('reset (r)'),
                  ),
                ],
              ),
            ),
          ),
          ConfettiWidget(confettiController: controller),
        ],
      ),
    );
  }
}

class GameOverState extends Cubit<bool> {
  GameOverState() : super(false);

  void toggle() {
    emit(!state);
  }
}

class DealerDialogue extends StatelessWidget {
  const DealerDialogue({super.key});

  @override
  Widget build(BuildContext context) {
    final FocusNode focusNode = FocusNode();
    void deal() {
      BlocProvider.of<DealerIsOffering>(context).toggle();
      BlocProvider.of<GameOverState>(context).toggle();
    }

    return BlocBuilder<DealerOffer, double>(
      builder: (context, state) {
        return KeyboardListener(
          focusNode: focusNode,
          autofocus: true,
          onKeyEvent: (event) {
            if (event is KeyDownEvent &&
                event.logicalKey == LogicalKeyboardKey.keyD) {
              deal();
            } else if (event is KeyDownEvent &&
                event.logicalKey == LogicalKeyboardKey.keyN) {
              BlocProvider.of<DealerIsOffering>(context).toggle();
            }
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Dealer offers you \$$state',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      deal();
                    },
                    child: Text('Deal! (D)'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      BlocProvider.of<DealerIsOffering>(context).toggle();
                    },
                    child: Text('No Deal! (N)'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    final FocusNode focusNode = FocusNode();
    return BlocBuilder<GameOverState, bool>(
      builder: (context, state) {
        return BlocProvider.of<GameOverState>(context).state
            ? GameOver(value: BlocProvider.of<DealerOffer>(context).state)
            : Scaffold(
              appBar: AppBar(
                backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                title: Text(title),
              ),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Boxes(),
                    BlocBuilder<FirstSuitcaseSelected, bool>(
                      builder: (context, state) {
                        return state
                            ? Text(
                              '',
                              style: Theme.of(context).textTheme.headlineMedium,
                            )
                            : Text(
                              'Pick a suitcase to hold!',
                              style: Theme.of(context).textTheme.headlineMedium,
                            );
                      },
                    ),
                    BlocBuilder<DealerIsOffering, bool>(
                      builder: (context, state) {
                        return state ? DealerDialogue() : Text('');
                      },
                    ),
                  ],
                ),
              ),
            );
      },
    );
  }
}
