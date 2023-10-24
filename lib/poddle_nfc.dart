
import 'poddle_nfc_platform_interface.dart';

class PoddleNfc {
  Future<String?> getPlatformVersion() {
    return PoddleNfcPlatform.instance.getPlatformVersion();
  }
}
