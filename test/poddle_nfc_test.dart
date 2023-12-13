import 'package:flutter_test/flutter_test.dart';
import 'package:poddle_nfc/poddle_nfc.dart';
import 'package:poddle_nfc/poddle_nfc_platform_interface.dart';
import 'package:poddle_nfc/poddle_nfc_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:poddle_nfc/src/poddle_nfc_android.dart';

class MockPoddleNfcPlatform with MockPlatformInterfaceMixin implements PoddleNfcPlatform {
  @override
  Future<String?> readNfc() => Future.value('42');

  @override
  Future<NFCStatus?> writeNfc({required String path, required String lable}) {
    throw UnimplementedError();
  }

  @override
  Stream<String?> streamNfc() {
    throw UnimplementedError();
  }

  @override
  Future<NFCAvailability?> isNFCAvailable() {
    throw UnimplementedError();
  }
}

void main() {
  final PoddleNfcPlatform initialPlatform = PoddleNfcPlatform.instance;

  test('$MethodChannelPoddleNfc is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelPoddleNfc>());
  });

  test('getPlatformVersion', () async {
    PoddleNfc poddleNfcPlugin = PoddleNfc();
    MockPoddleNfcPlatform fakePlatform = MockPoddleNfcPlatform();
    PoddleNfcPlatform.instance = fakePlatform;

    expect(await poddleNfcPlugin.readNfc(), '42');
  });
}
