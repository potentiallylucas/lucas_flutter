import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
// Lucas Nguyen
// Chopped from default flutter counter app

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: BlocProvider(
        create: (context) => QuestionAnswer(),
        child: const MyHomePage(title: 'Flutter Demo Home Page'),
      ),
    );
  }
}

class QuestionAnswer extends Cubit<Map<String, String>> { // cubit holds map w/ states and capitols
  QuestionAnswer() : super({});
  bool initialized = false;
  int index = 1; // holds index to iterate through the states

  void increment() {
    index++;
    emit(Map.from(state)); // allows rebuild
  }
  void initialize() async {
    final Directory dir = await getApplicationDocumentsDirectory();
    final File file = File('${dir.path}/StateCapitols.txt'); // file path

    if (await file.exists()) {
      final List<String> lines = await file.readAsLines();
      final Map<String, String> map = {};
      for (final String line in lines) { // creates map from file
        final List<String> parts = line.split(',');
        map[parts[0]] = parts[1];
      }
      initialized = true;
      emit(map);
    }
  }

  bool checkAnswer(String question, String answer) {
    return state[question] == answer; // checks if answer is correct
  }
}

class Correct extends StatelessWidget { // popup for correct answer
  const Correct ({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(actions: <Widget>[
          TextButton(
            child: const Text('Correct!'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],);
  }
}
class Incorrect extends StatelessWidget { //rather rude popup for incorrect answer
  const Incorrect ({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(actions: <Widget>[
          TextButton(
            child: const Text('WRONG!'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],);
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Enter the capitol for the given state:',
              style: TextStyle(fontSize: 24),
            ),
            BlocBuilder<QuestionAnswer, Map<String, String>>(
              builder: (context, state) {
                List keys = state.keys.toList();
                TextEditingController _controller = TextEditingController();
                return Column(children: [
                  Text(
                    BlocProvider.of<QuestionAnswer>(context).initialized
                        ? '${keys[BlocProvider.of<QuestionAnswer>(context).index]}'
                        : 'Waiting for initialization',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  TextField(
                    controller: _controller,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if(!BlocProvider.of<QuestionAnswer>(context).initialized){
                        BlocProvider.of<QuestionAnswer>(context).initialize();
                      }
                      else if(BlocProvider.of<QuestionAnswer>(context).checkAnswer(keys[BlocProvider.of<QuestionAnswer>(context).index], _controller.text)){
                        BlocProvider.of<QuestionAnswer>(context).increment();
                        showDialog(context: context, builder: (BuildContext context) => Correct());
                      } else {showDialog(context: context, builder: (BuildContext context) => Incorrect());}
                    },
                    child: Text(BlocProvider.of<QuestionAnswer>(context).initialized? "Submit" : "Initialize"))
                ]);
              },
            ),
          ],
        ),
      ),
    );
  }
}
