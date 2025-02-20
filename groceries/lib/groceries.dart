// groceries.dart
// Lucas Nguyen
// Chopped fr Dr Koster's file stuff
// Uses BlocProvider for state.
// currently hardcoded to paths within my computer

import "dart:io";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:path_provider/path_provider.dart";
// cd to the project directory
// > flutter pub add path_provider

class BufState
{ List<String> text = [];
  bool loaded = false;

  BufState( this.text, this.loaded );
}

class BufCubit extends Cubit<BufState>
{
  BufCubit() : super( BufState([], false) );

  void update(List<String> s) { emit( BufState(s,true) ); }
}

void main() 
{ runApp( FileStuff () );
}

class FileStuff extends StatelessWidget
{
  const FileStuff({super.key});

  @override
  Widget build( BuildContext context )
  { return MaterialApp
    ( title: "groceries",
      home: BlocProvider<BufCubit>
      ( create: (context) => BufCubit(),
        child: BlocBuilder<BufCubit,BufState>
        ( builder: (context,state) => FileStuff2(),
        ),
      ),
    );
  }
}

class FileStuff2 extends StatelessWidget
{
  const FileStuff2({super.key});

  @override
  Widget build( BuildContext context ) 
  { BufCubit bc = BlocProvider.of<BufCubit>(context);
    BufState bs = bc.state;

    TextEditingController tec = TextEditingController();
    tec.text = '';

    return Scaffold
    ( appBar: AppBar( title: Text("Groceries") ),
      body: Column
      ( children:
        [ Container
          ( height:300, width:400,
            decoration: BoxDecoration( border:Border.all(width:1)),
            child: makeListView(bs.text),
          ),
              bs.loaded
              ? Text("loaded")
              : Text("not loaded yet"),
              Container 
              ( height: 50, width: 200,
                decoration: BoxDecoration( border: Border.all(width:2) ),
                child: TextField
                (controller:tec, style: TextStyle(fontSize:20) ),
              ),
          FloatingActionButton
          ( onPressed: () async { writeFile(tec.text);
                           List<String> contents = await readFile(); 
                            bc.update(contents);
                            tec.text = '';},
            child: Text(bs.loaded ? "write" : 'initialize', style:TextStyle(fontSize:20)), //button serves both load and write purposes, if no file loaded then it's an "initialize" button
          ),
        ],
      ),
    );
  }

  ListView makeListView(List<String> text)
  {
    List<Widget> kids = text.map((item) => Text(item)).toList();

    ListView lv = ListView
    ( scrollDirection: Axis.vertical,
      itemExtent: 30,
      children: kids,
    );

    return lv;
  }

  Future<String> whereAmI() async
  {
    Directory mainDir = await getApplicationDocumentsDirectory();
    String mainDirPath = mainDir.path;
    // String mainDirPath = "App Dev Projects\labs\groceries\lists\list.txt";
    print("mainDirPath is $mainDirPath");
    return mainDirPath;
  }
  
  Future<List<String>> readFile() async
  { await Future.delayed( const Duration(seconds:0) ); // removes drama
    String myStuff = await whereAmI();
    String filePath = "$myStuff/App Dev Projects/labs/groceries/lists/list.txt"; // hardcoded
    File fodder = File(filePath);
    String contents = fodder.readAsStringSync();
    print("-------------in readFile ...");
    print(contents);
    return contents.split("\n");
  }

  Future<void> writeFile( String writeMe) async
  { String myStuff = await whereAmI();
    String filePath = "$myStuff/App Dev Projects/labs/groceries/lists/list.txt"; // hardcoded 
    File fodder = File(filePath);
    String contents = fodder.readAsStringSync(); // turn file to string, string to list, add item to list, remove blanks, write list to file as string
    List<String> items = contents.split('\n'); 
    items.add(writeMe);
    items.removeWhere((item) => item.isEmpty); // stops user from adding blank items, esp during initialization
    fodder.writeAsStringSync( items.join('\n') );
  }
}