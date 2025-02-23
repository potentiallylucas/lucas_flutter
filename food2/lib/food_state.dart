// food_state.dart
// Barrett Koster 2025
// 

import 'package:hydrated_bloc/hydrated_bloc.dart';

import 'munch.dart';

class FoodState
{ 
  List<Munch> munchies;

  FoodState(this.munchies);

  // turns the object into a map
  // I think this does not work.  It's too hard.

  
  Map<String,dynamic> toJson()
  { 
    return
    { 'munchies' : munchies ,
    };
  } 
  
  // turn a map back into an object
  factory FoodState.fromJson(Map<String,dynamic> map)
  {
    return FoodState( map['munchies'] );
  }
}

class FoodCubit extends HydratedCubit<FoodState> // with HydratedMixin
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

  
  @override
  FoodState fromJson(Map<String, dynamic> json) { 
    return FoodState.fromJson(json);
  }

  @override
  Map<String, dynamic> toJson(FoodState state){
    return state.toJson();
  }

  
}

