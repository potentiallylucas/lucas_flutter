// Barrett Koster 2025
// Boggle (more or less?)
// It shuffles a grid of letter-cubes and lets you make
// words by clicking on letters, then hit 'done' to 
// end word.

import "dart:math";
import "package:flutter/material.dart";

void main()
{ runApp(Boggle()); }

// This does ONE board of letters.
class Boggle extends StatelessWidget
{
  List<String> letters; // 16 letters that make the board
  Boggle({super.key}) : letters = shake() ; // note: shake()

  @override
  Widget build( BuildContext context )
  { return MaterialApp
    ( title: "Boggle",
      home: BoggleHome( letters ),
    );
  }
}

// return a list of 16 letters that are the top
// letters of the cubes shaken into place.
List<String> shake()
{
  List<String> cubes = 
  [ "AEANEG", "WNGEEH",
    "AHSPCO", "LNHNRZ",
    "ASPFFK", "TSTIYD",
    "OBJOAB", "OWTOAT",
    "IOTMUC", "ERTTYL",
    "RYVDEL", "TOESSI",
    "LREIXD", "TERWHV",
    "EIUNES", "NUIHMQ", // Q becomes Qu
  ];
  Random randy = Random();
  cubes.shuffle();

  // pick a random letter from each cube and add
  // it to 'letters'.
  List<String> letters = [];
  for ( int i=0; i<16; i++ )
  { int r = randy.nextInt(6); // needs dart:math
    String letter = cubes[i][r];
    letters.add(letter);
  }

  // print(letters);
  return letters;
}

class BoggleHome extends StatefulWidget
{
  final List<String> letters; // these are given in constructor

  const BoggleHome( this.letters, {super.key} );

  @override
  State<BoggleHome> createState() => BoggleHomeState( letters );
}

// This has the letter grid, which is fixed.
// It has 'word' so you can compose a work, and
// words, that keeps the list of words you made.
class BoggleHomeState extends State<BoggleHome>
{
  List<String> letters; // from above, fixed
  BoggleHomeState(this.letters);

  String word = ""; // shows letter by letter as a make a word.
  List<String> words = []; // list of words you have made.

  // FaceUps are the boxes on the screen with a letter.  
  // Primarily they are in the Columns and Rows below, but
  // we keep an extra list of them here to get to them
  // directly for reset().
  List<FaceUp> faceups = [];

  // This holds the FaceUps on the screen (a Column
  // of Rows of FaceUps).
  // Note that we assemble it with a 'for' loop, THEN
  // add it to the Scaffold.  
  Column faces = Column(children:<Row>[]);

  @override
  Widget build( BuildContext context )
  { // print("BoggleHomeState.build ... starting ...");
    int i=0;
    for ( int row=0; row<4; row++ )
    { Row r = Row(children:[]);
      for ( int col=0; col<4; col++ )
      { // print("adding letter ${letters[i]} to grid");
        FaceUp fup = FaceUp(letters[i], bhs:this );
        r.children.add( fup );
        faceups.add(fup);
        i++;
      }
      faces.children.add(r);
    }

    return Scaffold
    ( appBar: AppBar( title: Text("Boggle") ),
      body: Column
      ( children:
        [ faces, // This is the grid of letters to click on.

        // 'done' button (end of word)
        FloatingActionButton
        ( onPressed: ()
          { setState
            ( () 
              { words.add(word); 
                word=""; 
              } 
            );
            for ( FaceUp f in faceups )
            { f.fus!.reset( );
            }
          },
          child: Text("done",style:TextStyle(fontSize:20),),
        ),
        Text("word=$word"),
        Text("words=$words"),
        ],
      ),

    );
  }
}

// FaceUp is a single letter in a box on the screen.
// If you click on it, it highlights.
class FaceUp extends StatefulWidget
{
  String show;
  BoggleHomeState bhs; // This is the state of the enclosing app.
                       // We have to pass it down through the constructors
                       // so that a single letter can add itself to the word.
  FaceUpState? fus;

  FaceUp( this.show, {super.key, required this.bhs} );

  @override
  State<FaceUp> createState() => (fus=FaceUpState(show, bhs:bhs));
}

class FaceUpState extends State<FaceUp>
{
  String show;
  BoggleHomeState bhs; // And passed down again ... so we can add to the word.
  bool picked = false; // black border if picked.
                       // We should probably also disallow picking again.  Whatever.
  FaceUpState(this.show, {required this.bhs});

  // when a word is 'done', this is called to clear for next word.
  void reset() { setState((){ picked = false; }); }


  @override
  Widget build(BuildContext context )
  { return Listener // holds Container with letter, and listens
    ( onPointerDown: (_)
      { setState((){picked=true;} ); 
        bhs.setState( () {bhs.word += show;} );
      }, 
      child:    Container
      ( height: 50, width: 50,
        decoration: BoxDecoration // changes color if picked
        ( border: Border.all
          ( width:2, 
            color: picked? Color(0xff000000): Color(0xff00ff00), 
          ),
        ),
        child: Text(show, style: TextStyle(fontSize: 40) ),
      ),
    );
  }
}
