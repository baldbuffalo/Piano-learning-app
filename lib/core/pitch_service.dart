import 'dart:typed_data';
import 'dart:js_interop';
import 'dart:js_util'; // <-- For promiseToFuture
import 'package:fftea/fftea.dart';
import 'note_utils.dart';

@JS()
external JSAny get window;

@JS()
@staticInterop
class Navigator {
  external MediaDevices get mediaDevices;
}

@JS()
@staticInterop
class MediaDevices {
  external JSPromise getUserMedia(JSAny constraints);
}

@JS()
@staticInterop
class AudioContext {
  external MediaStreamAudioSourceNode createMediaStreamSource(MediaStream stream);
  external AnalyserNode createAnalyser();
  external int get sampleRate;
  external JSPromise close();
}

@JS()
@staticInterop
class MediaStreamAudioSourceNode {
  external void connect(AnalyserNode analyser);
}

@JS()
@staticInterop
class AnalyserNode {
  external int fftSize;
  external void getFloatTimeDomainData(Float32List buffer);
}

@JS()
@staticInterop
class MediaStream {}

class PitchService {
  AudioContext? _audioCtx;
  MediaStreamAudioSourceNode? _source;
  AnalyserNode? _analyser;
  bool _listening = false;

  void startListening(Function(String) onNoteDetected) async {
    if (_listening) return;
    _listening = true;

    // Get navigator.mediaDevices
    final nav = JS<Navigator>(window);
    final mediaDevices = nav.mediaDevices;

    // Request microphone access using promiseToFuture
    final stream = await promiseToFuture<JSAny>(
      mediaDevices.getUserMedia(JSAny.jsify({'audio': true})),
    ) as MediaStream;

    // Set up AudioContext
    _audioCtx = AudioContext();
    _source = _audioCtx!.createMediaStreamSource(stream);
    _analyser = _audioCtx!.createAnalyser();
    _analyser!.fftSize = 2048;
    _source!.connect(_analyser!);

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
      JS<void>(window)['requestAnimationFrame']!(allowInterop(analyze));
    }

    JS<void>(window)['requestAnimationFrame']!(allowInterop(analyze));
  }

  void stopListening() {
    _audioCtx?.close();
    _listening = false;
  }
}
