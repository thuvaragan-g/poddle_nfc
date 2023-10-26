import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:poddle_nfc/src/poddle_nfc_android.dart';

import 'poddle_nfc_platform_interface.dart';

/// An implementation of [PoddleNfcPlatform] that uses method channels.
class MethodChannelPoddleNfc extends PoddleNfcPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('poddle_nfc');

  @override
  Future<String?> getPlatformVersion() async {
    if (Platform.isIOS) {
      final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
      return version;
    } else {
      // final availability = await PoddleNfcReader.onTagDiscovered()
      // return availability.content;
      // final enable = await PoddleNfcReader.enableReaderMode();
      // if (enable.status != NFCStatus.reading) {

      //   }

      final value = await PoddleNfcReader.read();
      return value.content;
    }
  }

  @override
  Stream<String?> getStreamNfcData() {
    return PoddleNfcReader.onTagDiscovered().map((onData) {
      return onData.content;
    });
  }

  @override
  Future<NFCStatus> writeNfc({required String path, required String lable}) async {
    final value = await PoddleNfcReader.write(path, lable);
    return value.status;
  }
}
