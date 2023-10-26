import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:poddle_nfc/src/poddle_nfc_android.dart';

import 'poddle_nfc_method_channel.dart';

abstract class PoddleNfcPlatform extends PlatformInterface {
  /// Constructs a PoddleNfcPlatform.
  PoddleNfcPlatform() : super(token: _token);

  static final Object _token = Object();

  static PoddleNfcPlatform _instance = MethodChannelPoddleNfc();

  /// The default instance of [PoddleNfcPlatform] to use.
  ///
  /// Defaults to [MethodChannelPoddleNfc].
  static PoddleNfcPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [PoddleNfcPlatform] when
  /// they register themselves.
  static set instance(PoddleNfcPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<NFCStatus?> writeNfc({required String path, required String lable}) {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Stream<String?> getStreamNfcData() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
