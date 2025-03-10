import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BlocProvider(create: (context) => Counter(), 
      child: Page1())
    );
  }
}

class Counter extends Cubit<int> {
  Counter() : super(0);

  void increment() {
    emit(state+1);
  }
  void reset() {
    emit(0);
  }
}

class Page1 extends StatelessWidget {
  const Page1({super.key});

  @override
  Widget build(BuildContext context) {
    Counter cc = BlocProvider.of<Counter>(context);
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: BlocBuilder<Counter, int>(builder: (context, state) {
          return Column(children: [
            ElevatedButton(onPressed: cc.increment, child: Text('$state')),
            ElevatedButton(onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => Page2(i: state,)));
              }, 
            child: Text('Page 2'),
            )
          ],);
        })
      )
    );
  }
}

class Page2 extends StatelessWidget {
  const Page2({super.key, required this.i});
    final int i;

  @override
  Widget build(BuildContext context) {
    final File data = File("C:/Users/lucas/OneDrive/Documents/StateCapitols.txt");
    List<String> lines = data.readAsLinesSync();

    TextEditingController text = TextEditingController();
    return Scaffold(body: Center(child: Column(
      children: [
        BlocBuilder<Counter, int>(builder: (context, state){
          return Column(children: [
            ElevatedButton(onPressed: () {Navigator.of(context).pop();}, child: Text('return')),
            SizedBox(
            width: 200,
            height: 50,
            child: TextField(
              controller: text,
            )
            ),
            Text(lines.isNotEmpty ? lines[state] : 'false'),
          ],);
        })
      ],
    ),
    ));
  }
}