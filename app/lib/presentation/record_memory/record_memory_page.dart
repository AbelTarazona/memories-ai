import 'dart:async';
import 'dart:js_interop';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:memories/core/bloc/fetch_event.dart';
import 'package:memories/core/widgets/background_screen.dart';
import 'package:memories/core/widgets/circular_button.dart';
import 'package:memories/core/widgets/header_internals.dart';
import 'package:memories/presentation/record_memory/bloc/transcript_save_memory_bloc.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'dart:typed_data';
import 'package:web/web.dart' as web;

const theSource = AudioSource.microphone;

class RecordMemoryPage extends StatefulWidget {
  const RecordMemoryPage({super.key, this.autoStart = false});

  final bool autoStart;

  @override
  State<RecordMemoryPage> createState() => _RecordMemoryPageState();
}

class _RecordMemoryPageState extends State<RecordMemoryPage> {
  int _recordDuration = 0;
  Timer? _timer;
  bool _mRecorderIsInited = false;
  Codec _codec = Codec.aacMP4;
  String _mPath = 'tau_file.mp4';

  /// Our recorder
  FlutterSoundRecorder? _mRecorder = FlutterSoundRecorder();

  @override
  void initState() {
    openTheRecorder().then((value) {
      setState(() {
        _mRecorderIsInited = true;
      });

      // Si autoStart es true, iniciar grabación automáticamente
      if (widget.autoStart && _mRecorderIsInited) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted && !_mRecorder!.isRecording) {
            record();
          }
        });
      }
    });
    super.initState();
  }

  Future<Uint8List> blobUrlToBytes(String blobUrl) async {
    // 1) Convierte String -> JSString para cumplir con RequestInfo
    final jsInfo = blobUrl.toJS;

    // 2) fetch(...) devuelve un JSPromise<Response>
    final web.Response resp = await (web.window.fetch(jsInfo)).toDart;

    if (!resp.ok) {
      throw StateError('HTTP ${resp.status}: ${resp.statusText}');
    }

    // 3) arrayBuffer() -> JSPromise<JSArrayBuffer>
    final JSArrayBuffer jsBuffer = await (resp.arrayBuffer()).toDart;

    // 4) JSArrayBuffer -> ByteBuffer (Dart) -> Uint8List
    final ByteBuffer byteBuffer = jsBuffer.toDart;
    return Uint8List.view(byteBuffer);
  }

  @override
  void dispose() {
    _mRecorder!.closeRecorder();
    _mRecorder = null;
    _timer?.cancel();
    super.dispose();
  }

  /// Request permission to record something and open the recorder
  Future<void> openTheRecorder() async {
    await _mRecorder!.openRecorder();
    if (!await _mRecorder!.isEncoderSupported(_codec) && kIsWeb) {
      _codec = Codec.opusWebM;
      _mPath = 'tau_file.webm';
      if (!await _mRecorder!.isEncoderSupported(_codec) && kIsWeb) {
        _mRecorderIsInited = true;
        return;
      }
    }
    _mRecorderIsInited = true;
  }

  void record() {
    _mRecorder!
        .startRecorder(
          toFile: _mPath,
          codec: _codec,
          audioSource: theSource,
        )
        .then((value) {
          setState(() {});
        });
    _startTimer();
  }

  void stopRecorder() async {
    await _mRecorder!.stopRecorder().then((value) async {
      final bytes = await blobUrlToBytes(value!);
      _callGenerateImage(bytes);
    });
  }

  void _callGenerateImage(Uint8List bytes) {
    context.read<TranscriptSaveMemoryBloc>().add(FetchEvent(bytes));
    context.pop();
  }

  void _startTimer() {
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      setState(() => _recordDuration++);
    });
  }

  Widget _buildTimer() {
    final String minutes = _formatNumber(_recordDuration ~/ 60);
    final String seconds = _formatNumber(_recordDuration % 60);

    return Text(
      '$minutes : $seconds',
      style: const TextStyle(color: Colors.red),
    );
  }

  String _formatNumber(int number) {
    String numberStr = number.toString();
    if (number < 10) {
      numberStr = '0$numberStr';
    }

    return numberStr;
  }

  Widget _buildRecordStopControl() {
    late Widget icon;

    if (_mRecorder!.isRecording) {
      icon = const Icon(Icons.stop, color: Colors.red, size: 30);
    } else {
      icon = Icon(Icons.mic, color: Colors.black, size: 30);
    }

    return CircularButton(
      icon: Padding(
        padding: const EdgeInsets.all(15.0),
        child: icon,
      ),
      onTap: () {
        (_mRecorder!.isRecording) ? stopRecorder() : record();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundScreen(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            AppHeaderInternal(
              title: 'Grabar memoria',
              description:
                  'Presiona el botón para iniciar la grabación de tu memoria.',
            ),
            const SizedBox(height: 80),
            Visibility(
              visible: _mRecorder!.isRecording,
              maintainSize: true,
              maintainAnimation: true,
              maintainState: true,
              child: _buildTimer(),
            ),
            Lottie.asset('assets/lottie/dots.json'),
            _buildRecordStopControl(),
          ],
        ),
      ),
    );
  }
}
