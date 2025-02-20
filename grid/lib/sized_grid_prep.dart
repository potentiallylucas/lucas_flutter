// sized_grid_prep.dart
// Lucas Nguyen  2025 
// lab chopped from Dr. Koster's code
// let user enter 2D grid size, make grid that size

import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

void main()
{ runApp(SG()); }

class SG extends StatelessWidget
{
  const SG({super.key});

  @override
  Widget build( BuildContext context )
  {
    return MaterialApp
    ( title: "sized grid prep",
      home: BlocProvider(create: (context) => GridSize(),
       child: SG1()),
    );
  }
}

class GridSize extends Cubit<List<int>>
{
  GridSize() : super([4,3]);

  void setSize( int w, int h )
  { emit([w,h]); }

  int getWidth() => state[0];
  int getHeight() => state[1];
  
  
  void update(){
    emit(state);
  }
}

class SG1 extends StatelessWidget
{
  const SG1({super.key});

  @override
  Widget build( BuildContext context )
  { 


    return Scaffold
    ( appBar: AppBar( title: Text("sized grid") ),
      body: Column
      ( children:
        [ 
          BlocBuilder<GridSize, List<int>>(
            builder: (context, state) {
              int width = state[0];
              int height = state[1];
              Row theGrid = Row(children: []);
              for (int i = 0; i < width; i++) {
                Column c = Column(children: []);
                for (int j = 0; j < height; j++) {
                  c.children.add(Boxy(40, 40));
                }
                theGrid.children.add(c);
              }
              return theGrid;
            },
          ),
          ElevatedButton(onPressed: (){
            BlocProvider.of<GridSize>(context).setSize(BlocProvider.of<GridSize>(context).getWidth()+1, BlocProvider.of<GridSize>(context).getHeight());
            BlocProvider.of<GridSize>(context).update();
          },
           child: Text("Increase Width")),
          ElevatedButton(onPressed: (){
            BlocProvider.of<GridSize>(context).setSize(BlocProvider.of<GridSize>(context).getWidth(), BlocProvider.of<GridSize>(context).getHeight()+1);
            BlocProvider.of<GridSize>(context).update();
          },
           child: Text("Increase Height")),
           ElevatedButton(onPressed: (){
            BlocProvider.of<GridSize>(context).setSize(BlocProvider.of<GridSize>(context).getWidth()-1, BlocProvider.of<GridSize>(context).getHeight());
            BlocProvider.of<GridSize>(context).update();
          },
           child: Text("Decrease Width")),
          ElevatedButton(onPressed: (){
            BlocProvider.of<GridSize>(context).setSize(BlocProvider.of<GridSize>(context).getWidth(), BlocProvider.of<GridSize>(context).getHeight()-1);
            BlocProvider.of<GridSize>(context).update();
          },
           child: Text("Decrease Height")),
        ],
      ),
    );
  }
}

class Boxy extends Padding
{
  final double width;
  final double height;
  Boxy( this.width,this.height, {super.key} ) 
  : super
    ( padding: EdgeInsets.all(4.0),
      child: Container
      ( width: width, height: height,
        decoration: BoxDecoration
        ( border: Border.all(), ),
        child: Text("x"),
      ),
    );
}
