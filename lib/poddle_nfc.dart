import 'package:poddle_nfc/src/poddle_nfc_android.dart';

import 'poddle_nfc_platform_interface.dart';

class PoddleNfc {
  Future<String?> readNfc() {
    return PoddleNfcPlatform.instance.readNfc();
  }

  Future<NFCStatus?> writeNfc({required String path, required String lable}) {
    return PoddleNfcPlatform.instance.writeNfc(path: path, lable: lable);
  }

  Stream<String?> streamNfc() {
    return PoddleNfcPlatform.instance.streamNfc().map((content) {
      return content;
    });
  }

  Future<NFCAvailability?> isNFCAvailable() {
    return PoddleNfcPlatform.instance.isNFCAvailable();
  }
}
