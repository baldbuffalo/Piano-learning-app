import 'dart:typed_data';
import 'dart:js_interop';
import 'package:fftea/fftea.dart';
import 'note_utils.dart';

@JS()
external Navigator get navigator;

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

extension NavigatorAsyncExt on Navigator {
  Future<MediaStream> getUserMediaAsync(JSAny constraints) {
    final promise = mediaDevices.getUserMedia(constraints);
    final completer = Completer<MediaStream>();
    promise.then((value) {
      completer.complete(value as MediaStream);
    });
    return completer.future;
  }
}

class PitchService {
  AudioContext? _audioCtx;
  MediaStreamAudioSourceNode? _source;
  AnalyserNode? _analyser;
  bool _listening = false;

  void startListening(Function(String) onNoteDetected) async {
    if (_listening) return;
    _listening = true;

    // Request microphone access using JS interop
    final stream = await navigator.getUserMediaAsync(jsify({'audio': true}));

    // Setup audio context and analyser
    _audioCtx = AudioContext();
    _source = _audioCtx!.createMediaStreamSource(stream);
    _analyser = _audioCtx!.createAnalyser();
    _analyser!.fftSize = 2048;
    _source!.connect(_analyser!);

    final buffer = Float32List(_analyser!.fftSize);

    void analyze(num _) {
      _analyser!.getFloatTimeDomainData(buffer);

      // FFT using fftea
      final fft = FFT(buffer.length);
      final spectrum = fft.process(buffer.toList());

      // Find peak
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

      window.requestAnimationFrame(analyze);
    }

    window.requestAnimationFrame(analyze);
  }

  void stopListening() {
    _audioCtx?.close();
    _listening = false;
  }
}
