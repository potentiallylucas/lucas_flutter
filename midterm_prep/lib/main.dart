import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

TextStyle ts = TextStyle(fontSize: 30);

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'yeagh',
      home: BlocProvider(
        create: (context) => CounterCubit(),
        child: TestClass(),
      ),
    );
  }
}

class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);

  void increment() {
    emit(state + 1);
  }
  void reset() {
    emit(0);
  }
}

class TestClass extends StatelessWidget {
  const TestClass({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(actions: []),
      body: Center( 
        child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BlocBuilder<CounterCubit, int>(
            builder: (  context, state) {
              return Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      BlocProvider.of<CounterCubit>(context).increment();
                    },
                    child: Text('$state'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      BlocProvider.of<CounterCubit>(context).reset();
                    },
                    child: Text('reset'),
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
