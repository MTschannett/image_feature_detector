import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:image_feature_detector/image_feature_detector.dart';
import 'package:path_provider/path_provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  String _filePath;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await ImageFeatureDetector.getVersionString;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    try {
      var directory = await getTemporaryDirectory();
      var path = "${directory.path}/tmp.png";

      setState(() {
        _filePath = path;
      });
    } on PlatformException {}

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    // var image = _filePath == null ? Container() : Image.file(File(_filePath));

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
            child: Column(
          children: <Widget>[Text('Running on: $_platformVersion\n')],
        )),
        floatingActionButton: FloatingActionButton(
            child: Icon(Icons.image),
            onPressed: () async => {
                  print(await ImageFeatureDetector.detectRectangles(_filePath)),
                }),
      ),
    );
  }
}
