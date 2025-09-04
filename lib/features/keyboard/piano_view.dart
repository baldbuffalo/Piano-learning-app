import 'package:flutter/material.dart';
import 'package:piano/piano.dart';

class PianoView extends StatelessWidget {
  final String highlightNote; // e.g. "C4", "F#3", "None"

  const PianoView({super.key, required this.highlightNote});

  @override
  Widget build(BuildContext context) {
    final parsed = _parseNote(highlightNote);

    return Center(
      child: InteractivePiano(
        // Highlight the detected key if parsed successfully
        highlightedNotes: parsed == null
            ? const []
            : [NotePosition(note: parsed.$1, octave: parsed.$2)],
        naturalColor: Colors.white,
        accidentalColor: Colors.black,
        keyWidth: 46,
        // Show a reasonable 2-octave range
        noteRange: NoteRange.forClefs(const [Clef.Treble]),
        onNotePositionTapped: (pos) {
          // If you want, you can also show taps,
          // but mic-detected notes will be highlighted automatically.
        },
      ),
    );
  }

  /// Returns (Note, octave) or null if not parseable.
  (Note, int)? _parseNote(String s) {
    if (s.isEmpty || s == 'None') return null;

    // Extract name and octave (supports sharps, e.g., C#, F#)
    final match = RegExp(r'^([A-G]#?)(-?\d)$').firstMatch(s.trim());
    if (match == null) return null;

    final name = match.group(1)!;
    final octave = int.parse(match.group(2)!);

    final map = {
      'C': Note.C,
      'C#': Note.CS,
      'D': Note.D,
      'D#': Note.DS,
      'E': Note.E,
      'F': Note.F,
      'F#': Note.FS,
      'G': Note.G,
      'G#': Note.GS,
      'A': Note.A,
      'A#': Note.AS,
      'B': Note.B,
    };

    final note = map[name];
    if (note == null) return null;
    return (note, octave);
  }
}
