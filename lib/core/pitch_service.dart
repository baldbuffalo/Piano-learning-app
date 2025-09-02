import 'dart:typed_data';
import 'dart:html' as html;
import 'package:fftea/fftea.dart';
import 'note_utils.dart';

class PitchService {
  bool _listening = false;
  final int fftSize = 2048;

  void startListening(Function(String) onNoteDetected) async {
    if (_listening) return;
    _listening = true;

    // Request microphone access
    final stream = await html.window.navigator.mediaDevices!
        .getUserMedia({'audio': true});

    final audioCtx = html.AudioContext();
    final source = audioCtx.createMediaStreamSource(stream);
    final analyser = audioCtx.createAnalyser();
    analyser.fftSize = fftSize;
    source.connect(analyser);

    final buffer = Float32List(fftSize);
    final fft = FFT(fftSize); // FFT object

    void analyze(num _) {
      analyser.getFloatTimeDomainData(buffer);

      // Convert Float32List -> Float64List for fftea
      final input = Float64List.fromList(buffer.map((e) => e.toDouble()).toList());

      // Perform FFT
      final spectrum = fft.realFft(input); // <-- correct method

      // Find peak frequency
      int peakIndex = 0;
      double maxVal = 0;
      for (int i = 0; i < spectrum.length; i++) {
        if (spectrum[i].abs() > maxVal) {
          maxVal = spectrum[i].abs();
          peakIndex = i;
        }
      }

      final freq = peakIndex * audioCtx.sampleRate! / fftSize;
      final note = NoteUtils.getClosestNote(freq);
      onNoteDetected(note);

      if (_listening) html.window.requestAnimationFrame(analyze);
    }

    html.window.requestAnimationFrame(analyze);
  }

  void stopListening() {
    _listening = false;
  }
}
