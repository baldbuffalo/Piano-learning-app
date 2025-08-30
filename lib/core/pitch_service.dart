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

    final stream = await html.window.navigator.mediaDevices!.getUserMedia({'audio': true});
    _audioCtx = html.AudioContext();
    _source = _audioCtx!.createMediaStreamSource(stream);
    _analyser = _audioCtx!.createAnalyser();
    _source!.connectNode(_analyser!);

    final buffer = Float32List(_analyser!.fftSize);

    void analyze() {
      _analyser!.getFloatTimeDomainData(buffer);
      final spectrum = FFT().Transform(buffer);
      int peakIndex = 0;
      double maxVal = 0;

      for (int i = 0; i < spectrum.length; i++) {
        if (spectrum[i].abs() > maxVal) {
          maxVal = spectrum[i].abs();
          peakIndex = i;
        }
      }

      final freq = peakIndex * _audioCtx!.sampleRate / buffer.length;
      final note = NoteUtils.getClosestNote(freq);
      onNoteDetected(note);

      html.window.requestAnimationFrame((_) => analyze());
    }

    analyze();
  }

  void stopListening() {
    _audioCtx?.close();
    _listening = false;
  }
}
