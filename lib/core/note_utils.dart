class NoteUtils {
  // Equal-tempered tuning reference
  static const double a4 = 440.0;

  /// Convert frequency (Hz) -> nearest note name like "C4", "D#4", etc.
  static String getClosestNote(double freq) {
    if (freq <= 0 || freq.isNaN) return 'None';

    // midi note from frequency
    final midi = (69 + 12 * (log2(freq / a4))).round();
    final octave = (midi ~/ 12) - 1;
    final names = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B'];
    final name = names[midi % 12];

    return '$name$octave';
  }

  static double log2(double x) => (x).log() / 2.0.log();
}

extension on double {
  double log() => (this > 0) ? (this).toString().contains('e')
      ? (this).ln()
      : (this).ln() // delegate
      : double.nan;

  // quick natural log using Dart's math library
  double ln() => _Math.ln(this);
}

// minimal wrapper to avoid importing math everywhere
class _Math {
  static final _ln = (double x) => math.log(x);
  // ignore: library_private_types_in_public_api
  static double ln(double x) => _ln(x);
}

import 'dart:math' as math;
