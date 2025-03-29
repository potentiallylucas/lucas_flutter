import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

// API KEY: 9e5065e3dfd243c3b6e201636251103

void main() {
  runApp(const MyApp());
}

class GetWeather extends Cubit<String> {
  GetWeather() : super('YIPPEE');

  void apiCall() async {
    final weatherCall = await http.get(
      Uri.parse(
        'http://api.weatherapi.com/v1/current.json'
        '?key=9e5065e3dfd243c3b6e201636251103&q=90802&aqi=no',
      ),
    );
    Map<String, dynamic> dataAsMap = jsonDecode(weatherCall.body);

    double tempC = dataAsMap['current']['temp_c'];
    String stringTemp = tempC.toString();

    emit(stringTemp);
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
        create: (context) => GetWeather(),
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
            BlocBuilder<GetWeather, String>(
              builder: (context, state) {
                return Text('$state degrees Celsius', style: TextStyle(fontSize: 50),);
              },
            ),
            ElevatedButton(onPressed: BlocProvider.of<GetWeather>(context).apiCall, child: Text('Refresh'))
          ],
        ),
      ),
    );
  }
}
