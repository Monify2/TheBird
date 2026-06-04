import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';

class AgoraService {
  static const String _appId = 'YOUR_AGORA_APP_ID';
  RtcEngine? _engine;

  Future<void> initialize() async {
    await Permission.microphone.request();
    await Permission.camera.request();
    
    _engine = await createAgoraRtcEngine();
    await _engine?.initialize(
      RtcEngineContext(
        appId: _appId,
      ),
    );
  }

  Future<void> joinChannel(String channelName) async {
    if (_engine == null) return;
    await _engine?.joinChannel(
      token: '',
      channelId: channelName,
      uid: 0,
      options: const ChannelMediaOptions(),
    );
  }

  Future<void> leaveChannel() async {
    await _engine?.leaveChannel();
  }

  Future<void> release() async {
    await _engine?.release();
    _engine = null;
  }
}
