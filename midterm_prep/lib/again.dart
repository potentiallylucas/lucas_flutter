import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    Future<Directory> dir = getApplicationDocumentsDirectory();
    File data = File('$dir/data.txt');
    return MaterialApp(
      title: 'title',
      home: BlocProvider(create: (context) => Counter(), child: Home()),
    );
  }
}

class Counter extends Cubit<int> {
  Counter() : super(0);

  void increment() {
    emit(state + 1);
  }

  void reset() {
    emit(0);
  }
}

class Page2 extends StatelessWidget {
  Page2({super.key});
  TextEditingController text = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('yeagh'),
            ElevatedButton(
              onPressed: Navigator.of(context).pop,
              child: Text('pop!'),
            ),
            SizedBox(
              width: 200,
              height: 50,
              child: TextField(
                controller: text,
              )
            ),
            ElevatedButton(onPressed: () {
              String entered = text.text;
              print(entered);
            }
            , child: Text('print'))
          ],
        ),
      ),
    );
  }
}

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            BlocBuilder<Counter, int>(
              builder: (context, state) {
                return Column(
                  children: [
                    ElevatedButton(
                      onPressed: BlocProvider.of<Counter>(context).increment,
                      child: Text('$state'),
                    ),
                    ElevatedButton(
                      onPressed: BlocProvider.of<Counter>(context).reset,
                      child: Text('reset'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => Page2()),
                        );
                      },
                      child: Text('Page 2'),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
