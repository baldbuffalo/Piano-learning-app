// NOTE: dart:html is deprecated in favor of package:web + js_interop,
// but it still works on Flutter Web. We silence the lint for web only.
// ignore: deprecated_member_use
import 'dart:html' as html;
import 'dart:typed_data';

import 'note_utils.dart';

class PitchService {
  html.AudioContext? _ctx;
  html.AnalyserNode? _analyser;
  bool _running = false;

  /// Start mic + pitch loop. Calls [onNote] with note names like "C4".
  Future<void> startListening(void Function(String note) onNote) async {
    if (_running) return;
    _running = true;

    // Request mic
    final stream = await html.window.navigator.mediaDevices!
        .getUserMedia({'audio': true});

    // Audio context + nodes
    _ctx = html.AudioContext();
    final source = _ctx!.createMediaStreamSource(stream);
    _analyser = _ctx!.createAnalyser();

    // Configure analyser
    _analyser!
      ..fftSize = 2048
      ..minDecibels = -90
      ..maxDecibels = -10
      ..smoothingTimeConstant = 0.85;

    source.connectNode(_analyser!);

    final buffer = Float32List(_analyser!.fftSize);

    void tick(num _) {
      if (!_running || _ctx == null || _analyser == null) return;

      // Pull time-domain signal
      _analyser!.getFloatTimeDomainData(buffer);

      // Estimate pitch via autocorrelation
      final freq = _estimatePitchHz(buffer, _ctx!.sampleRate.toDouble());

      final note = NoteUtils.getClosestNote(freq);
      onNote(note);

      html.window.requestAnimationFrame(tick);
    }

    html.window.requestAnimationFrame(tick);
  }

  void stopListening() {
    _running = false;
    _ctx?.close();
    _ctx = null;
    _analyser = null;
  }

  /// Very small/fast autocorrelation for monophonic pitch.
  /// Returns 0 if no stable pitch is found.
  double _estimatePitchHz(Float32List signal, double sampleRate) {
    final int size = signal.length;
    // Remove DC offset
    final mean = signal.reduce((a, b) => a + b) / size;
    for (var i = 0; i < size; i++) {
      signal[i] = signal[i] - mean;
    }

    // Energy gate to ignore silence
    double rms = 0;
    for (var i = 0; i < size; i++) rms += signal[i] * signal[i];
    rms = math.sqrt(rms / size);
    if (rms < 0.01) return 0; // too quiet

    final int minLag = (sampleRate / 1000).floor(); // ~1000 Hz max
    final int maxLag = (sampleRate / 50).floor();   // ~50 Hz min

    int bestLag = -1;
    double bestCorr = 0;

    for (int lag = minLag; lag <= maxLag && lag < size; lag++) {
      double corr = 0;
      for (int i = 0; i < size - lag; i++) {
        corr += signal[i] * signal[i + lag];
      }
      if (corr > bestCorr) {
        bestCorr = corr;
        bestLag = lag;
      }
    }

    if (bestLag <= 0) return 0;
    final freq = sampleRate / bestLag;
    return freq.isFinite ? freq : 0;
  }
}

import 'dart:math' as math;
