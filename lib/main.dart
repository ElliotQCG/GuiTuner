import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math' as math;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GuiTuner',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        scaffoldBackgroundColor: Colors.black,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.orange),
            foregroundColor: MaterialStateProperty.all(Colors.black),
          ),
        ),
        
      ),
      home: MyHomePage(title: 'GuiTuner'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {
  Map<String, String> _guitarStrings = {
    'E1': 'sounds/E1.mp3',
    'B2': 'sounds/B2.mp3',
    'G3': 'sounds/G3.mp3',
    'D4': 'sounds/D4.mp3',
    'A5': 'sounds/A5.mp3',
    'E6': 'sounds/E6.mp3',
  };
  List<String> _tuningOutcomes = ['In tune', 'Tune down', 'Tune up'];
  String _selectedString = 'E1';
  String _tuningOutcome = '';
  bool _isListening = false;
  final AudioPlayer _audioPlayer = AudioPlayer();

  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  Future<void> playSound() async {
    await _audioPlayer.play(
      AssetSource(_guitarStrings[_selectedString]!),
    );
  }

  void simulateTuning() {
    setState(() {
      _isListening = true;
    });

    playSound();

    final random = Random();
    int index = random.nextInt(_tuningOutcomes.length);
    String tuningOutcome = _tuningOutcomes[index];

    Future.delayed(Duration(seconds: 3)).then((_) {
      setState(() {
        _tuningOutcome = tuningOutcome;
        _isListening = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              color: Colors.white,
              child: DropdownButton<String>(
                value: _selectedString,
                onChanged: (newValue) {
                  setState(() {
                    _selectedString = newValue!;
                  });
                },
                style: TextStyle(color: Colors.black),
                items: _guitarStrings.keys.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),

            Visibility(
              visible: _isListening, // Controls the visibility
              child: AnimatedBuilder(
                animation: _waveController,
                builder: (_, __) {
                  return CustomPaint(
                    size: Size(200, 100),
                    painter: WavePainter(waveValue: math.sin(_waveController.value * 2 * math.pi)),
                  );
                },
              ),
            ),
            Text(
              _tuningOutcome,
              style: Theme.of(context).textTheme.headline4?.copyWith(color: Colors.white),
            ),
            ElevatedButton(
              onPressed: simulateTuning,
              child: Text('Start tuning!'),
            ),
            Container(
              margin: EdgeInsets.only(top: 50.0),
              child: Image.asset('assets/images/GuitarNeck.png'),
            ),
          ],
        ),
      ),
    );
  }
}

class WavePainter extends CustomPainter {
  final double waveValue;

  WavePainter({required this.waveValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.orange
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(0, size.height / 2);

    for (int i = 0; i < size.width.toInt(); i++) {
      path.lineTo(i.toDouble(), size.height / 2 + 30 * math.sin(waveValue * 2 * math.pi * i / size.width));
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
