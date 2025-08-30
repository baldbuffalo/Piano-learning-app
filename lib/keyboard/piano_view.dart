import 'package:flutter/material.dart';
import 'package:piano/piano.dart';

class PianoView extends StatelessWidget {
  final String highlightNote;
  const PianoView({super.key, required this.highlightNote});

  @override
  Widget build(BuildContext context) {
    final notes = ["C4","D4","E4","F4","G4","A4","B4","C5"];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: notes.map((note) {
          final isHighlighted = note == highlightNote;
          return Container(
            width: 60,
            height: 200,
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: isHighlighted ? Colors.blue : Colors.white,
              border: Border.all(color: Colors.black),
            ),
            child: Center(
              child: Text(
                note,
                style: TextStyle(
                  color: isHighlighted ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
