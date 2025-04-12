// ani1.dart
// Barrett Koster 2025
// demo of implicit animation.

import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

class Coords {
  double x, y;
  Coords(this.x, this.y);
}

// DragState keeps track of the position of ONE box as you
// drag it.  When you click down, it does a 3-second
// transition to hte new coordinates (using
// AnimatedPositioned as the base).
class DragState {
  Coords zat; // position of left corner of draggable box
  Curve curve;

  DragState(this.zat, this.curve);
}

class DragCubit extends Cubit<DragState> {
  DragCubit(Coords here) : super(DragState(here, Curves.bounceOut));

  // mouse goes down here, so set new position
  void down(TapDownDetails td) {
    Coords here = Coords(td.localPosition.dx, td.localPosition.dy);
    print('${td.localPosition.dx}, ${td.localPosition.dy}');
    emit(DragState(here, Curves.linear));
    Future.delayed(Duration(milliseconds: 1000), () {
      fallStep();
    });
  }

  void fallStep() {
    if (state.zat.y < 400) {
      emit(DragState(Coords(state.zat.x, 400), Curves.bounceOut));
    }
  }
}

void main() // 23
{
  runApp(Dragger());
}

class Dragger extends StatelessWidget {
  const Dragger({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dragger',
      home: BlocProvider<DragCubit>(
        create: (context) => DragCubit(Coords(100, 100)),
        child: BlocBuilder<DragCubit, DragState>(
          builder: (context, state) {
            return Dragger2();
          },
        ),
      ),
    );
  }
}

class Dragger2 extends StatelessWidget {
  Dragger2({super.key});

  @override
  Widget build(BuildContext context) {
    DragCubit dg = BlocProvider.of<DragCubit>(context);
    return Scaffold(
      appBar: AppBar(title: Text("ani1")),
      body: GestureDetector(
        onTapDown: (TapDownDetails td) => dg.down(td),
        child: Container(
          width: 500,
          height: 500,
          decoration: BoxDecoration(border: Border.all(width: 2)),
          child: Stack(children: [Tile("W", dg.state.zat, dg.state.curve)]),
        ),
      ),
    );
  }
}

class Tile extends StatelessWidget {
  final String face;
  final Coords here;
  final Curve curve;
  Tile(this.face, this.here, this.curve);

  @override
  Widget build(BuildContext context) {
    return Tile2(face, here, curve);
  }
}

class Tile2 extends AnimatedPositioned {
  final String face;
  final Coords where;
  final Curve animCurve;

  Tile2(this.face, this.where, this.animCurve)
    : super(
        duration: Duration(seconds: 1),
        curve: animCurve,
        left: where.x,
        top: where.y,
        child: Container(
          height: 100,
          width: 100,
          decoration: BoxDecoration(
            border: Border.all(width: 2),
          ),
          child: Text(face),
        ),
      );
}
