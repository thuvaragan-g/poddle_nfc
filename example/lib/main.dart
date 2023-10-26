import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:poddle_nfc/poddle_nfc.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  final _poddleNfcPlugin = PoddleNfc();

  List<String> chars = [
    "NUL",
    "SOH",
    "STX",
    "ETX",
    "EOT",
    "ENQ",
    "ACK",
    "BEL",
    "BS",
    "HT",
    "LF",
    "VT",
    "FF",
    "CR",
    "SO",
    "SI",
    "DLE",
    "DC1",
    "DC2",
    "DC3",
    "DC4",
    "NAK",
    "SYN",
    "ETB",
    "CAN",
    "EM",
    "SUB",
    "ESC",
    "FS",
    "GS",
    "RS",
    "US"
  ];

  @override
  void initState() {
    super.initState();
    // initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion = await _poddleNfcPlugin.getPlatformVersion() ?? 'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
    List<String> chars = ['', ''];

    // Create a RegExp pattern that matches all the control characters
    String pattern = chars.join('|');
    RegExp regExp = RegExp(pattern);

    // Use the replaceAll method to remove control characters from the text
    String sanitizedText = platformVersion.replaceAll(regExp, '');
    setState(() {
      _platformVersion = sanitizedText;
    });
  }

  initAndroidNfcListener() {
    try {
      _poddleNfcPlugin.getStreamNfcData().listen((data) {
        print(data);
        setState(() {
          _platformVersion = data ?? "";
        });
      });
    } on PlatformException {
      _platformVersion = 'Failed stram to get nfc.';
    }
  }

  writeNFC() async {
    final data = await _poddleNfcPlugin.writeNfc(path: "This is path...", lable: "this is lable text...");
    print(data);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () => initPlatformState(),
        ),
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Text('Running on: $_platformVersion\n'),
        ),
      ),
    );
  }
}
