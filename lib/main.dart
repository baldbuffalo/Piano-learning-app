import 'package:flutter/material.dart';
import 'package:simply_piano_clone/features/keyboard/piano_view.dart';
import 'package:simply_piano_clone/core/pitch_service.dart';

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
  String detectedNote = "None";

  @override
  void initState() {
    super.initState();
    _pitchService.startListening((note) {
      setState(() {
        detectedNote = note;
      });
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
      title: "Simply Piano Clone",
      home: Scaffold(
        appBar: AppBar(title: const Text("Simply Piano Clone")),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                "Detected Note: $detectedNote",
                style: const TextStyle(fontSize: 24),
              ),
            ),
            Expanded(child: PianoView(highlightNote: detectedNote)),
          ],
        ),
      ),
    );
  }
}
