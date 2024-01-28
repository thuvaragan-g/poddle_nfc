import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:poddle_nfc/src/poddle_nfc_android.dart';

import 'poddle_nfc_platform_interface.dart';

/// An implementation of [PoddleNfcPlatform] that uses method channels.
class MethodChannelPoddleNfc extends PoddleNfcPlatform {
  @visibleForTesting
  final methodChannel = const MethodChannel('poddle_nfc');

  @override
  Future<NFCAvailability?> isNFCAvailable() async {
    final value = await PoddleNfcReader.isNFCAvailable();
    return value;
  }

  @override
  Future<String?> readNfc() async {
    if (Platform.isIOS) {
      final value = await methodChannel.invokeMethod<String>('NfcRead');
      return value;
    } else {
      final value = await PoddleNfcReader.read();
      return value.content;
    }
  }

  @override
  Stream<String?> streamNfc() {
    return PoddleNfcReader.onTagDiscovered().map((onData) {
      return onData.content;
    });
  }

  @override
  Future<NFCStatus> writeNfc({required String path, required String lable}) async {
    final value = await PoddleNfcReader.write(path, lable);
    return value.status;
  }

  @override
  Future<void> stopNfc() async {
    if (Platform.isAndroid) {
      await PoddleNfcReader.stop();
    }
  }
}
