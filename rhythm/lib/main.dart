import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = await HydratedStorage.build(
    storageDirectory: HydratedStorageDirectory(
      await getApplicationDocumentsDirectory().then((dir) => dir.path),
    ), // setup for hydrated storage
  );

  HydratedBloc.storage = storage;

  runApp(
    BlocProvider(
      create: (_) => LeaderboardCubit(),
      child: MaterialApp(
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlueAccent),
        ),
        home: const Rhythm(),
      ),
    ),
  );
}

class LeaderboardEntry {
  // this is what's made after a run ends and is fed into leaderboard
  final String name;
  final String song;
  final double score;

  LeaderboardEntry({
    required this.name,
    required this.song,
    required this.score,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'song': song,
    'score': score,
  }; // converting to and from json

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      name: json['name'] as String,
      song: json['song'] as String,
      score: (json['score'] as num).toDouble(),
    );
  }
}

class LeaderboardCubit extends HydratedCubit<List<LeaderboardEntry>> {
  // this is what stores the leaderboard entries
  LeaderboardCubit() : super([]);

  void addEntry(LeaderboardEntry entry) {
    // called when game ends and player hits submit
    final updated = List<LeaderboardEntry>.from(state)..add(entry);
    updated.sort((a, b) => b.score.compareTo(a.score)); // high to low
    emit(updated);
  }

  void removeEntry(LeaderboardEntry entry) {
    // called from button on leaderboard
    final updated = List<LeaderboardEntry>.from(state)..remove(entry);
    emit(updated);
  }

  @override
  List<LeaderboardEntry> fromJson(Map<String, dynamic> json) {
    return (json['entries'] as List)
        .map((e) => LeaderboardEntry.fromJson(e))
        .toList();
  }

  @override
  Map<String, dynamic> toJson(List<LeaderboardEntry> state) {
    return {'entries': state.map((e) => e.toJson()).toList()};
  }

  void reset() {
    emit([]);
  }
}

class Rhythm extends StatefulWidget {
  const Rhythm({super.key});
  @override
  State<Rhythm> createState() => RhythmState();
}

// enum for the type of note in the song
enum NoteCommand { rest, a, s, d, f }

// visual representation of the note falling
class FallingNote {
  final int position; // should be from 0 to 3, corresponding to a s d f
  double y = 0;
  final double spawnTime; // seconds into the song when this note spawns in

  FallingNote({required this.position, required this.spawnTime});
}

// this is the main game screen where pretty much all of the logic is. Stateful widget is used because of the
// sheer amount of state variables that I need to make the timing and scoring and everything else work
class RhythmState extends State<Rhythm> with SingleTickerProviderStateMixin {
  final FocusNode focusNode = FocusNode(); // focus node for the key presses
  final Set<LogicalKeyboardKey> pressedKeys = {};
  final List<FallingNote> activeNotes = []; // what notes are on the screen
  final TextEditingController nameController =
      TextEditingController(); // only used for entering name on run finish
  double score = 100; // score starts at 100% and degrades with inaccuracy
  String? overlayMessage; // used to show misses
  String selectedSong =
      "placeholder"; // updated when user picks a song in the UI
  double get songDuration =>
      (songs[selectedSong]?.length ?? 0) * 0.5 + 2.0; // for the progress bar
  // notes are played every half second and take 2 seconds to fall to bottom of screen
  late final Ticker
  ticker; // the little magic variable used for ALL of the timing
  double elapsedTime = 0;
  bool isPlaying = false;

  final Map<String, List<NoteCommand>> songs = {
    // hardcoded. the note commands play in half second intervals
    "Mary Had a Little Lamb": [
      NoteCommand.d,
      NoteCommand.s,
      NoteCommand.a,
      NoteCommand.s,
      NoteCommand.d,
      NoteCommand.d,
      NoteCommand.d,
      NoteCommand.rest,
      NoteCommand.s,
      NoteCommand.s,
      NoteCommand.s,
      NoteCommand.rest,
      NoteCommand.d,
      NoteCommand.f,
      NoteCommand.f,
      NoteCommand.rest,
      NoteCommand.d,
      NoteCommand.s,
      NoteCommand.a,
      NoteCommand.s,
      NoteCommand.d,
      NoteCommand.d,
      NoteCommand.d,
      NoteCommand.d,
      NoteCommand.s,
      NoteCommand.s,
      NoteCommand.d,
      NoteCommand.s,
      NoteCommand.a,
    ],
    "Hot Cross Buns": [
      NoteCommand.d,
      NoteCommand.s,
      NoteCommand.a,
      NoteCommand.rest,
      NoteCommand.d,
      NoteCommand.s,
      NoteCommand.a,
      NoteCommand.rest,
      NoteCommand.a,
      NoteCommand.a,
      NoteCommand.s,
      NoteCommand.s,
      NoteCommand.d,
      NoteCommand.s,
      NoteCommand.a,
    ],
  };

  @override
  void initState() {
    super.initState();
    focusNode.requestFocus();

    ticker = createTicker((elapsed) {
      final screenHeight = MediaQuery.of(context).size.height;
      final targetFallTime =
          2.0 *
          (screenHeight - 80) /
          screenHeight; // time after spawn when note hits target point

      elapsedTime = elapsed.inMilliseconds / 1000.0;

      for (var note in activeNotes) {
        // updates the falling notes
        double t = (elapsedTime - note.spawnTime) / 2.0;
        note.y = t.clamp(0.0, 1.0) * screenHeight;
      }

      bool missed = false; // removes missed notes and triggers overlay

      for (int i = activeNotes.length - 1; i >= 0; i--) {
        final note = activeNotes[i];
        if (elapsedTime >= note.spawnTime + targetFallTime + 0.25) {
          activeNotes.removeAt(i);
          missed = true;
        }
      }

      if (missed) {
        // triggers when player lets note hit bottom of screen without pressing button
        setState(() {
          overlayMessage = "Miss! -20";
          score = (score - 20).clamp(0, 100); // subtract 20 safely
        });

        Future.delayed(const Duration(milliseconds: 400), () {
          if (mounted) {
            setState(() {
              overlayMessage = null; // resets overlay message
            });
          }
        });
      }
      // updates score
      setState(() {});
    });
  }

  // starts the song
  Future<void> startSong() async {
    final song = songs[selectedSong]; // gets song by name
    if (song == null || song.isEmpty) return;

    playSound(
      'silence.mp3',
    ); // my quick and dirty attempt at getting rid of the audio player's cold start latency
    // doesn't work great but it's better than nothing
    setState(() {
      // song initialization
      score = 100.0;
      isPlaying = true;
      elapsedTime = 0;
      activeNotes.clear();
    });

    ticker.stop(); // reset timer
    ticker.start();

    final startTime = DateTime.now();

    for (var command in song) {
      final sinceStart = // how long has it been since the song's started?
          DateTime.now().difference(startTime).inMilliseconds / 1000.0;

      if (command != NoteCommand.rest) {
        final pos = commandToPosition(
          command,
        ); // adds a note once its interval arrives (assuming it's not a rest)
        activeNotes.add(FallingNote(position: pos, spawnTime: sinceStart));
      }

      await Future.delayed(const Duration(milliseconds: 500));
    }

    await Future.delayed(
      const Duration(seconds: 2),
    ); // delay to let the last note actually fall
    ticker.stop();
    setState(() => isPlaying = false);
    if (score > 50) {
      // only winners get cheers
      playSound("cheer.mp3");
    } else {
      playSound("boo.mp3");
    }
    showFinalScoreDialog();
  }

  int commandToPosition(NoteCommand cmd) {
    // function for figuring out where on the screen a falling note should appear
    switch (cmd) {
      case NoteCommand.a:
        return 0;
      case NoteCommand.s:
        return 1;
      case NoteCommand.d:
        return 2;
      case NoteCommand.f:
        return 3;
      default:
        return -1;
    }
  }

  Future<void> playSound(String filename) async {
    // plays sound. tried to make it low latency but didn't seem
    // to have much of an effect
    final player = AudioPlayer();
    await player.play(AssetSource(filename), mode: PlayerMode.lowLatency);
  }

  Future<void> handleA() async => await playSound('c.wav');
  Future<void> handleS() async => await playSound('d.wav');
  Future<void> handleD() async => await playSound('e.wav');
  Future<void> handleF() async => await playSound('g.wav');

  void checkNoteHit(int position) {
    final screenHeight = MediaQuery.of(context).size.height;
    final targetFallTime = 2.0 * (screenHeight - 80) / screenHeight;

    final candidates = activeNotes.where(
      (note) => note.position == position,
    ); // checks for notes in lane

    FallingNote? bestMatch;
    double smallestTimeDiff = double.infinity;

    for (final note in candidates) {
      final timeDiff = (elapsedTime - note.spawnTime - targetFallTime).abs();
      if (timeDiff < smallestTimeDiff) {
        // a bit of a holdover from when i tried to add leniency windows
        smallestTimeDiff = timeDiff;
        bestMatch = note;
      }
    }

    if (bestMatch != null) {
      // if there's a note in the lane, subtract a point for every 10th of a second of inaccuracy
      final penalty = (smallestTimeDiff / 0.1);
      setState(() {
        score = (score - penalty).clamp(0, 100);
        activeNotes.remove(bestMatch);
      });
    } else {
      // if there's no note in the lane, subtract 10 points
      setState(() {
        score = (score - 10).clamp(0, 100);
        overlayMessage = "Miss! -10";
      });
    }

    Future.delayed(const Duration(milliseconds: 400), () {
      // remove overlay message
      if (mounted) {
        setState(() {
          overlayMessage = null;
        });
      }
    });
  }

  void onKeyEvent(KeyEvent event) {
    // keypress reader!
    final key = event.logicalKey;

    if (event is KeyDownEvent && !pressedKeys.contains(key)) {
      pressedKeys.add(key);
      setState(() {});

      int? position;
      if (key == LogicalKeyboardKey.keyA) {
        position = 0;
        handleA();
      } else if (key == LogicalKeyboardKey.keyS) {
        position = 1;
        handleS();
      } else if (key == LogicalKeyboardKey.keyD) {
        position = 2;
        handleD();
      } else if (key == LogicalKeyboardKey.keyF) {
        position = 3;
        handleF();
      }

      if (position != null) {
        checkNoteHit(position);
      }
    }

    if (event is KeyUpEvent) {
      pressedKeys.remove(key);
      setState(() {});
    }
  }

  void showFinalScoreDialog() {
    // popup that prompts user to submit score to leaderboard
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text("End of Song!"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Your Score: ${score.toStringAsFixed(1)}"),
              const SizedBox(height: 12),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Enter your name"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                final name = nameController.text.trim();
                final entry = LeaderboardEntry(
                  name: name.isEmpty ? "Stranger" : name,
                  song: selectedSong,
                  score: score,
                );
                context.read<LeaderboardCubit>().addEntry(entry);
                Navigator.of(context).pop();
                nameController.clear();
              },
              child: const Text("Submit"),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    ticker.dispose();
    focusNode.dispose();
    nameController.dispose();
    super.dispose();
  }

  Widget buildKeyLane(
    // these are the buttons at the bottom of the screen
    String label,
    LogicalKeyboardKey key,
    Future<void> Function() onPressed,
    int position,
  ) {
    final isPressed = pressedKeys.contains(key);
    return Expanded(
      child: GestureDetector(
        onTap: () => onPressed(),
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            color: isPressed ? Colors.orangeAccent : Colors.grey.shade300,
            border: Border(
              bottom: BorderSide(width: 6, color: Colors.blueGrey),
              top: BorderSide(width: 6, color: Colors.blueGrey),
              left: BorderSide(width: 3, color: Colors.blueGrey),
              right: BorderSide(width: 3, color: Colors.blueGrey),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // main game screen
    return Scaffold(
      backgroundColor: Colors.white,
      body: KeyboardListener(
        focusNode: focusNode,
        onKeyEvent: onKeyEvent,
        child: Stack(
          children: [
            Row(
              // backgrounds for the lanes
              children: List.generate(4, (index) {
                final colors = [
                  Colors.cyan[50],
                  Colors.cyan[100],
                  Colors.cyan[200],
                  Colors.cyan[300],
                ];

                return Expanded(child: Container(color: colors[index]));
              }),
            ),
            ...activeNotes.map((note) {
              // the falling notes visualization
              double laneWidth = MediaQuery.of(context).size.width / 4;
              double left = note.position * laneWidth;

              return Positioned(
                top: note.y,
                left: left,
                child: Container(
                  width: laneWidth,
                  height: 20,
                  color: Colors.blueAccent,
                ),
              );
            }),
            if (overlayMessage != null) // overlay message for missed notes
              Center(
                child: Container(
                  color: Colors.red.shade200,
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    overlayMessage!,
                    style: const TextStyle(
                      fontSize: 32,
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            Positioned(
              // These are the buttons at the bottom of the screen
              bottom: 0,
              left: 0,
              right: 0,
              child: Row(
                children: [
                  buildKeyLane("A", LogicalKeyboardKey.keyA, handleA, 0),
                  buildKeyLane("S", LogicalKeyboardKey.keyS, handleS, 1),
                  buildKeyLane("D", LogicalKeyboardKey.keyD, handleD, 2),
                  buildKeyLane("F", LogicalKeyboardKey.keyF, handleF, 3),
                ],
              ),
            ),
            Positioned(
              // This is the progress bar for the song
              top: 20,
              left: 20,
              child: Container(
                width: 500,
                height: 30,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: (elapsedTime / songDuration).clamp(0.0, 1.0),
                        minHeight: 30,
                        backgroundColor: Colors.blueAccent,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.lightBlue,
                        ),
                      ),
                    ),
                    Text(
                      "Progress: ${(100 * elapsedTime / songDuration).clamp(0, 100).toStringAsFixed(0)}%",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              // this is the accuracy bar, showing score
              top: 70,
              left: 20,
              child: Container(
                width: 500,
                height: 30,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: (score / 100).clamp(0.0, 1.0),
                        minHeight: 30,
                        backgroundColor: Colors.grey,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color.fromARGB(255, 225, 124, 158),
                        ),
                      ),
                    ),
                    Text(
                      "Accuracy: ${score.toStringAsFixed(1)}%",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              // navigation for the leaderboard
              bottom: 100,
              right: 20,
              child: FloatingActionButton.extended(
                heroTag: "leaderboard_btn",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LeaderboardPage()),
                  );
                },
                label: const Text("Leaderboard"),
                icon: const Icon(Icons.leaderboard),
              ),
            ),
            Positioned(
              // play button for mary had a little lamb
              bottom: 170,
              right: 20,
              child: FloatingActionButton.extended(
                heroTag: "lamb_btn",
                onPressed:
                    isPlaying
                        ? null
                        : () {
                          setState(
                            () => selectedSong = "Mary Had a Little Lamb",
                          );
                          startSong();
                        },
                label: const Text("Mary Had a Little Lamb"),
                icon: const Icon(Icons.cloud), // it kinda looks like a sheep?
              ),
            ),
            Positioned(
              // play button for hot cross buns
              bottom: 240,
              right: 20,
              child: FloatingActionButton.extended(
                heroTag: "buns_btn",
                onPressed:
                    isPlaying
                        ? null
                        : () {
                          setState(() => selectedSong = "Hot Cross Buns");
                          startSong();
                        },
                label: const Text("Hot Cross Buns"),
                icon: const Icon(Icons.cookie), // no bread icon :(
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LeaderboardPage extends StatelessWidget {
  const LeaderboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Leaderboard"),
        actions: [
          IconButton(
            // button brings up a confirmation popup to delete all leaderboard entries
            icon: const Icon(Icons.delete_forever),
            tooltip: 'Clear leaderboard',
            onPressed: () {
              showDialog(
                context: context,
                builder:
                    (_) => AlertDialog(
                      title: const Text("Clear Leaderboard"),
                      content: const Text(
                        "Are you sure you want to delete all scores?",
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Cancel"),
                        ),
                        TextButton(
                          onPressed: () {
                            context.read<LeaderboardCubit>().reset();
                            Navigator.pop(context);
                          },
                          child: const Text("Clear"),
                        ),
                      ],
                    ),
              );
            },
          ),
        ],
      ),

      body: BlocBuilder<LeaderboardCubit, List<LeaderboardEntry>>(
        builder: (context, entries) {
          if (entries.isEmpty) {
            return const Center(child: Text("No scores yet."));
          }

          return ListView.builder(
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];
              return ListTile(
                leading: Text("#${index + 1}"),
                title: Text(entry.name),
                subtitle: Text("Song: ${entry.song}"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(entry.score.toStringAsFixed(1)),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      tooltip: "Delete this entry",
                      onPressed: () {
                        context.read<LeaderboardCubit>().removeEntry(entry);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
