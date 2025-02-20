// Lucas Nguyen 2025
// Chopped up from Dr. Koster's code
// You can pretend to buy cans, I suppose.

import "package:flutter/material.dart";

void main()
{ runApp(CokeCan()); }

// This does ONE board of letters.
class CokeCan extends StatelessWidget
{
  List<String> letters; // 16 letters that make the board
  CokeCan({super.key}) : letters = shake() ; // note: shake()

  @override
  Widget build( BuildContext context )
  { return MaterialApp
    ( title: "CokeCan",
      home: BoggleHome( letters ),
    );
  }
}

// return a list of 16 letters that are the top
// letters of the cubes shaken into place.
List<String> shake()
{
  // pick a random letter from each cube and add
  // it to 'letters'.
  List<String> letters = [];
  for ( int i=1; i<26; i++ )
  { 
    String letter = i.toString();
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

  List<String> word = []; // shows letter by letter as a make a word.
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
    for ( int row=0; row<5; row++ )
    { Row r = Row(children:[]);
      for ( int col=0; col<5; col++ )
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
              { words = words + word; 
                word=[]; 
              } 
            );
            for ( FaceUp f in faceups )
            { 
              if (f.fus!.isPicked())
              { f.fus!.reset( );
              }
            }
          },
          child: Text("Buy",style:TextStyle(fontSize:20),),
        ),
        Text("Current Selection=$word"),
        Text("Purchased Cans=$words"),
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
  bool isClickable = true;
  bool bought = false;
                       // We should probably also disallow picking again.  Whatever.
  FaceUpState(this.show, {required this.bhs});
  isPicked()
  {
    return picked;
  }
  // when a word is 'done', this is called to clear for next word.
  void reset() { setState((){ 
    picked = false; 
    bought = true;
    }); }


  @override
  Widget build(BuildContext context )
  { return Listener // holds Container with letter, and listens
    ( onPointerDown: (_)
      { if(isClickable)
        {
        setState((){picked=true;} ); 
        bhs.setState( () {bhs.word.add(show);} );
        isClickable = false;
        }
      }, 
      child:    Container
      ( height: 50, width: 50,
        decoration: BoxDecoration // changes color if picked
        ( border: Border.all
          ( width:2, 
            color: picked? Color(0xff000000): Color(0xff00ff00), 
          ),
        ),
        child: Text(bought ? '' : show, style: TextStyle(fontSize: 40) ),
      ),
    );
  }
}
