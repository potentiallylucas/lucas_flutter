// food_state.dart
// Barrett Koster 2025
// 

import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import 'munch.dart';

class FoodState
{ 
  List<Munch> munchies;

  FoodState(this.munchies);

  // turns the object into a map
  // I think this does not work.  It's too hard.
  Map<String,dynamic> toMap()
  { 
    return
    { 'munchies' : munchies ,
    };
  } 
  
  // turn a map back into an object
  factory FoodState.fromMap(Map<String,dynamic> map)
  {
    return FoodState( map['munchies'] );
  }

  // turns the object into JSON.  Does this by 
  // call toMap and then encode() ing the map.
  String toJson() => json.encode(toMap);

  // turns Json back into an objevct.  
  factory FoodState.fromJson( String source) 
  => FoodState.fromMap( json.decode(source));
   
}

class FoodCubit extends /*Hydrated*/Cubit<FoodState> // with HydratedMixin
{
  FoodCubit() : super( FoodState([ Munch("apple",/*99*/ "2025-01-02 10:43:17" ),
                                   Munch("banana", /*99*/"2025-01-03 8:41:00" ),
                                 ]) );

  void setFood(List<Munch> m ) { emit( FoodState(m) ); }

  void addFood( String f )
  { Munch m = Munch( f, /*99*/ DateTime.now().toString() );
    state.munchies.add(m);
    emit( FoodState(state.munchies) );
  }

  
  // converts the map form of FDState into an object.
  // Should have been called fromMap, as the Hydrated stuff
  // will have already converted it from JSON to a map.
  // @override
  FoodState fromJson( Map<String,dynamic> map)
  { return FoodState.fromMap(map); }

  // This is called on state AFTER emit(state).  Every time there is a new
  // state, this function converts it to a Map and the Hydrated
  // stuff takes it from there.  
  // @override
  Map<String,dynamic> toJson( FoodState state )
  { return state.toMap(); }
  

}

