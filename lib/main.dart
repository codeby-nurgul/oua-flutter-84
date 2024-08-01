import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TimerProvider()),
        ChangeNotifierProvider(create: (_) => NoteProvider()),
      ],
      child: MaterialApp(
        title: 'FocusNote',
        theme: ThemeData(
          primarySwatch: Colors.red,
          scaffoldBackgroundColor: Colors.red[50],
        ),
        debugShowCheckedModeBanner: false,
        home: PomodoroScreen(),
      ),
    );
  }
}

class TimerProvider with ChangeNotifier {
  static const int workTime = 25 * 60;
  static const int breakTime = 5 * 60;

  int _remainingTime = workTime;
  bool _isRunning = false;
  bool _isWorkTime = true;
  int _pomodoroCount = 0;
  Timer? _timer;

  int get remainingTime => _remainingTime;
  bool get isRunning => _isRunning;
  bool get isWorkTime => _isWorkTime;
  int get pomodoroCount => _pomodoroCount;

  void startTimer() {
    if (!_isRunning) {
      _isRunning = true;
      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
        if (_remainingTime > 0) {
          _remainingTime--;
          notifyListeners();
        } else {
          _isRunning = false;
          _isWorkTime = !_isWorkTime;
          if (_isWorkTime) {
            _pomodoroCount++;
          }
          _remainingTime = _isWorkTime ? workTime : breakTime;
          notifyListeners();
          timer.cancel();
        }
      });
    }
  }

  void stopTimer() {
    if (_isRunning) {
      _isRunning = false;
      _timer?.cancel();
      notifyListeners();
    }
  }

  void resetTimer() {
    _isRunning = false;
    _remainingTime = _isWorkTime ? workTime : breakTime;
    _timer?.cancel();
    notifyListeners();
  }
}

class NoteProvider with ChangeNotifier {
  List<String> _notes = [];

  List<String> get notes => _notes;

  void addNote(String note) {
    _notes.add(note);
    notifyListeners();
  }

  void removeNoteAt(int index) {
    _notes.removeAt(index);
    notifyListeners();
  }
}

class PomodoroScreen extends StatefulWidget {
  @override
  _PomodoroScreenState createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen> {
  @override
  Widget build(BuildContext context) {
    final timerProvider = Provider.of<TimerProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Pomodoro Timer', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.redAccent,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              timerProvider.isWorkTime ? 'Work Time' : 'Break Time',
              style: TextStyle(fontSize: 30, color: Colors.redAccent),
            ),
            SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              padding: EdgeInsets.all(20),
              child: Text(
                formatTime(timerProvider.remainingTime),
                style: TextStyle(fontSize: 80, color: Colors.redAccent),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: timerProvider.isRunning
                      ? timerProvider.stopTimer
                      : timerProvider.startTimer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: timerProvider.isRunning ? Colors.redAccent : Colors.greenAccent,
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                  child: Text(timerProvider.isRunning ? 'Stop' : 'Start'),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: timerProvider.resetTimer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orangeAccent,
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                  child: Text('Reset'),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              'Pomodoros Completed: ${timerProvider.pomodoroCount}',
              style: TextStyle(fontSize: 24, color: Colors.redAccent),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NoteScreen()),
                );
              },
              child: Text('Notes'),
            ),
          ],
        ),
      ),
    );
  }

  String formatTime(int seconds) {
    final int minutes = seconds ~/ 60;
    final int remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}

class NoteScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notes', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.redAccent,
      ),
      body: Column(
        children: <Widget>[
          NoteInputField(),
          Expanded(
            child: NoteList(),
          ),
        ],
      ),
    );
  }
}

class NoteInputField extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Add a note',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              if (_controller.text.isNotEmpty) {
                Provider.of<NoteProvider>(context, listen: false).addNote(_controller.text);
                _controller.clear();
              }
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }
}

class NoteList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final noteProvider = Provider.of<NoteProvider>(context);

    return ListView.builder(
      itemCount: noteProvider.notes.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(noteProvider.notes[index]),
          trailing: IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              noteProvider.removeNoteAt(index);
            },
          ),
        );
      },
    );
  }
}
