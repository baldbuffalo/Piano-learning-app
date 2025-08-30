class NoteUtils {
  static const Map<String, double> notes = {
    "C4": 261.63,
    "D4": 293.66,
    "E4": 329.63,
    "F4": 349.23,
    "G4": 392.00,
    "A4": 440.00,
    "B4": 493.88,
    "C5": 523.25,
  };

  static String getClosestNote(double freq) {
    String closest = "C4";
    double minDiff = double.infinity;
    for (var entry in notes.entries) {
      double diff = (entry.value - freq).abs();
      if (diff < minDiff) {
        minDiff = diff;
        closest = entry.key;
      }
    }
    return closest;
  }
}
