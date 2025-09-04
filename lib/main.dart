import 'package:flutter/material.dart';
import 'core/pitch_service.dart';
import 'features/keyboard/piano_view.dart';

void main() {
  runApp(const SimplyPianoClone());
}

class SimplyPianoClone extends StatefulWidget {
  const SimplyPianoClone({super.key});

  @override
  State<SimplyPianoClone> createState() => _SimplyPianoCloneState();
}

class _SimplyPianoCloneState extends State<SimplyPianoClone> {
  final PitchService _pitchService = PitchService();
  String _detectedNote = 'None';

  @override
  void initState() {
    super.initState();
    _pitchService.startListening((note) {
      if (!mounted) return;
      setState(() => _detectedNote = note);
    });
  }

  @override
  void dispose() {
    _pitchService.stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Simply Piano Clone',
      home: Scaffold(
        appBar: AppBar(title: const Text('Simply Piano Clone')),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 12),
            Center(
              child: Text(
                'Detected Note: $_detectedNote',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(child: PianoView(highlightNote: _detectedNote)),
          ],
        ),
      ),
    );
  }
}
