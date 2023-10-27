import 'package:poddle_nfc/src/poddle_nfc_android.dart';

import 'poddle_nfc_platform_interface.dart';

class PoddleNfc {
  Future<String?> getPlatformVersion() {
    return PoddleNfcPlatform.instance.getPlatformVersion();
  }

  Future<NFCStatus?> writeNfc({required String path, required String lable}) {
    return PoddleNfcPlatform.instance.writeNfc(path: path, lable: lable);
  }

  Stream<String?> getStreamNfcData() {
    return PoddleNfcPlatform.instance.getStreamNfcData().map((content) {
      return content;
    });
  }
}
