import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poddle_nfc/poddle_nfc_method_channel.dart';

void main() {
  MethodChannelPoddleNfc platform = MethodChannelPoddleNfc();
  const MethodChannel channel = MethodChannel('poddle_nfc');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.readNfc(), '42');
  });
}
