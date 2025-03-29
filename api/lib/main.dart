import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;


void main() {
  runApp(const MyApp());
}

class GetEmoji extends Cubit<String> {
  GetEmoji() : super('1F917');

  void apiCall() async {
    final emojiCall = await http.get(
      Uri.parse(
        'https://emojihub.yurace.pro/api/random'),
    );
    Map<String, dynamic> dataAsMap = jsonDecode(emojiCall.body);

    String unicode = dataAsMap['unicode'][0];
    unicode = unicode.substring(2);

    emit(unicode);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: BlocProvider(
        create: (context) => GetEmoji(),
        child: MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(''),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            BlocBuilder<GetEmoji, String>(
              builder: (context, state) {
                return Text(String.fromCharCode(int.parse('0x$state')), style: TextStyle(fontSize: 200));
              },
            ),
            ElevatedButton(onPressed: BlocProvider.of<GetEmoji>(context).apiCall, child: Text('Random Emoji'))
          ],
        ),
      ),
    );
  }
}
