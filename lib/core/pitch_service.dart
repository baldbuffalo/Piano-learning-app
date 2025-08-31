import 'dart:html' as html;
import 'dart:typed_data';
import 'package:fft/fft.dart';
import 'note_utils.dart';

class PitchService {
  html.AudioContext? _audioCtx;
  html.MediaStreamAudioSourceNode? _source;
  html.AnalyserNode? _analyser;
  bool _listening = false;

  void startListening(Function(String) onNoteDetected) async {
    if (_listening) return;
    _listening = true;

    // Request mic access
    final stream = await html.window.navigator.mediaDevices!.getUserMedia({'audio': true});
    _audioCtx = html.AudioContext();
    _source = _audioCtx!.createMediaStreamSource(stream);
    _analyser = _audioCtx!.createAnalyser();
    _analyser!.fftSize = 2048; // Set FFT size
    _source!.connect(_analyser!); // connectNode deprecated → use connect

    final buffer = Float32List(_analyser!.fftSize);

    void analyze(num _) {
      _analyser!.getFloatTimeDomainData(buffer);

      // Convert Float32List to List<double> for FFT
      final spectrum = FFT().Transform(buffer.toList());

      // Find peak
      int peakIndex = 0;
      double maxVal = 0;
      for (int i = 0; i < spectrum.length; i++) {
        if (spectrum[i].abs() > maxVal) {
          maxVal = spectrum[i].abs();
          peakIndex = i;
        }
      }

      // Calculate frequency
      final freq = peakIndex * _audioCtx!.sampleRate / buffer.length;
      final note = NoteUtils.getClosestNote(freq);
      onNoteDetected(note);

      // Continue analyzing
      html.window.requestAnimationFrame(analyze);
    }

    html.window.requestAnimationFrame(analyze);
  }

  void stopListening() {
    _audioCtx?.close();
    _listening = false;
  }
}
