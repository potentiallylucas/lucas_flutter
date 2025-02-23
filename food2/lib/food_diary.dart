// food_diary.dart 
// Barrett Koster
// working on the core page

import "dart:io";
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';

import 'food_state.dart';
import 'munch.dart';


void main() async
{ WidgetsFlutterBinding.ensureInitialized();
  Directory addx = await getApplicationDocumentsDirectory();
  String add = addx.path;
  HydratedBloc.storage = await HydratedStorage.build
  (  storageDirectory: HydratedStorageDirectory
    ( (await getApplicationDocumentsDirectory()).path,),
  );
  print("add=$add");
  runApp(const FoodDiary());
}

class FoodDiary extends StatelessWidget
{ static const String header = "Food Diary 5";

  const FoodDiary({super.key});

  @override
  Widget build(BuildContext context) 
  { return MaterialApp
    ( title: header,
      home: BlocProvider<FoodCubit>
      ( create: (context) => FoodCubit(),
        child: BlocBuilder<FoodCubit,FoodState>
        ( builder: (context,state)
          { // FDCubit fdc =  BlocProvider.of<FDCubit>(context);
            return  Core(title: header, /* fdc:fdc */ );
          },
        ),
      ),
    );
  }
}

class Core extends StatelessWidget 
{ final String title;
  // final FDCubit fdc;
  const Core({super.key, required this.title } );

  @override
  Widget build(BuildContext context) 
  { FoodCubit fc = BlocProvider.of<FoodCubit>(context);
    FoodState fs = fc.state;
    TextEditingController tec = TextEditingController();

    // print("json=${fs.toJson()}"); fail, it's too hard

    return Scaffold
    ( appBar: AppBar(  title: Text(title),),
      body: Column
      ( children: 
        [ Container
          ( height:300, width:400,
            decoration: BoxDecoration( border:Border.all(width:1)),
            child: makeListView(context),
          ),
          SizedBox
          ( height:50, width:300,
            child: TextField(controller: tec ),
          ),
          ElevatedButton
          ( onPressed: (){ fc.addFood(tec.text); },
            child: Text("submit"),
          ),
        ],
      ),
    );
  }     

  ListView makeListView( BuildContext context )
  { FoodCubit fc = BlocProvider.of<FoodCubit>(context);
    FoodState fs = fc.state;
    List<Munch> theList = fs.munchies;

    List<Widget> kids = [];
    for ( Munch m in theList )
    { 
      String s = m.what;
      kids.add(Text(s));
    }

    ListView lv = ListView
    ( scrollDirection: Axis.vertical,
      itemExtent: 30,
      children: kids,
    );

    return lv;
  }



}
