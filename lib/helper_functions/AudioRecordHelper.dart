import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:audio_recorder/audio_recorder.dart';
import 'dart:io';

class AudioRecordHelper {
  final String _taskId;

  AudioRecordHelper(this._taskId);

  Future<String> get _localPath async {
    final directory = await getExternalStorageDirectory();
    return directory.path;
  }

  Future<bool> startRecording() async {
    PermissionStatus status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      return false;
    }

    String path = await this._localPath;
    String outputFile = '$path/${this._taskId}.aac';
    try {
      await AudioRecorder.start(
          path: outputFile, audioOutputFormat: AudioOutputFormat.AAC);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> stopRecording() async {
    try {
      Recording recording = await AudioRecorder.stop();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteRecording() async {
    try {
      String path = await this._localPath;
      File outputFile = File('$path/${this._taskId}.aac');
      await outputFile.delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  void dispose() {}
}

class AudioPlayerHelper {
  final String _taskId;
  AudioPlayer _player = new AudioPlayer();

  AudioPlayerHelper(this._taskId);

  Future<String> get _localPath async {
    final directory = await getExternalStorageDirectory();
    return directory.path;
  }

  Future<bool> startPlaying() async {
    String path = await this._localPath;
    String outputFile = '$path/${this._taskId}.aac';
    try {
      int result = await _player.play(outputFile, isLocal: true, volume: 10.0);
      if (result == 1) {
        return true;
      }

      return false;
    } catch (e) {
      print('error $e');
      return false;
    }
  }

  Future<bool> stopPlaying() async {
    int result = await _player.stop();
    if (result == 1) {
      return true;
    }
    return false;
  }
}
