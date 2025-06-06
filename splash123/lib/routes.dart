// Barrett Koster
// demo of Routing/Navigation
// Thisis the first version, simple.
// The button names a new Route.

import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

TextStyle ts = TextStyle(fontSize: 30);

class CounterState {
  int count;
  CounterState(this.count);
}

class CounterCubit extends Cubit<CounterState> {
  CounterCubit() : super(CounterState(0));

  void inc() {
    emit(CounterState(state.count + 1));
  }
}

void main() {
  runApp(RoutesDemo());
}

class RoutesDemo extends StatelessWidget {
  const RoutesDemo({super.key});

  @override
  Widget build(BuildContext context) {
    String title = "Routes Demo";
    return MaterialApp(title: title, home: TopBloc());
  }
}

// TobBloc layer makes/provides the CounterCubit.
class TopBloc extends StatelessWidget {
  const TopBloc({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CounterCubit>(
      create: (context) => CounterCubit(),
      child: BlocBuilder<CounterCubit, CounterState>(
        builder: (context, state) => Route1(),
      ),
    );
  }
}

// This is page 1.  Note that we are already inside a
// MaterialApp, and the CounterCubit can be extracted
// from the context, so all we need is Scaffold.
class Route1 extends StatelessWidget {
  final String title = "Route1";

  const Route1({super.key});

  @override
  Widget build(BuildContext context) {
    CounterCubit cc = BlocProvider.of<CounterCubit>(context);
    return Scaffold(
      appBar: AppBar(title: Text(title, style: ts)),
      body: Column(
        children: [
          Text("page 1", style: ts),
          Text("${cc.state.count}", style: ts),
          ElevatedButton(
            onPressed: () {
              cc.inc();
            },
            child: Text("add 1", style: ts),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (context) => Route2(cc: cc)));
            },
            child: Text("page 2", style: ts),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (context) => Route3(cc: cc)));
            },
            child: Text("page 3", style: ts),
          ),
        ],
      ),
    );
  }
}

// Route2.  This is inside a MaterialPageRoute, so it
// just needs the Scaffold.  But, we start with
// BlocProvider.value  *VALUE*  to take the existing
// CounterCubit passed as an argument. Then there's
// the BlocBuilder layer and then the Scaffold.
class Route2 extends StatelessWidget {
  final String title = "Route2";
  final CounterCubit cc;
  const Route2({required this.cc, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CounterCubit>.value // use existing CounterCubit
    (
      value: cc,
      child: BlocBuilder<CounterCubit, CounterState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(title: Text(title, style: ts)),
            body: Column(
              children: [
                Text("page 2", style: ts),
                Text("${cc.state.count}", style: ts),
                ElevatedButton(
                  onPressed: () {
                    cc.inc();
                  },
                  child: Text("add 1", style: ts),
                ),
                ElevatedButton(
                  onPressed: () { // wrap Route1 in blocprovider so it doesn't crash
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => BlocProvider<CounterCubit>.value(
                        value: cc,
                        child: Route1(),
                        )),
                    );
                  },
                  child: Text("page 1", style: ts),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => Route3(cc: cc)),
                    );
                  },
                  child: Text("page 3", style: ts),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class Route3 extends StatelessWidget { // same as Route2
  final String title = "Route3";
  final CounterCubit cc;
  const Route3({required this.cc, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CounterCubit>.value // use existing CounterCubit
    (
      value: cc,
      child: BlocBuilder<CounterCubit, CounterState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(title: Text(title, style: ts)),
            body: Column(
              children: [
                Text("page 3", style: ts),
                Text("${cc.state.count}", style: ts),
                ElevatedButton(
                  onPressed: () {
                    cc.inc();
                  },
                  child: Text("add 1", style: ts),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => BlocProvider<CounterCubit>.value(
                        value: cc,
                        child: Route1(),
                        )),
                    );
                  },
                  child: Text("page 1", style: ts),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => Route2(cc: cc)),
                    );
                  },
                  child: Text("page 2", style: ts),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
