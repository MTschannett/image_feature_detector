import 'dart:io';

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
  Contour _contour;

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
      var directory2 = await getApplicationDocumentsDirectory();

      var directory = await getTemporaryDirectory();
      var path = "${directory2.path}/images/tmp.png";

      var file = File(path);
      if (!await file.exists()) {
        var data = await rootBundle.load("images/rectangle.png");

        try {
          await file.create(recursive: true);
        } catch (e) {
          print(e);
        }

        file.writeAsBytes(
            data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
      }

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
    Column c;

    if (_contour != null) {
      c = Column(
        children: _contour.contour.map((p) {
          return Text("X: ${p.x}, Y: ${p.y}");
        }).toList(),
      );
    } else {
      c = Column(
        children: <Widget>[Text("No contour calculated")],
      );
    }

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
            child: Column(
          children: <Widget>[Text('Running on: $_platformVersion\n'), c],
        )),
        floatingActionButton: FloatingActionButton(
            child: Icon(Icons.image),
            onPressed: () async {
              try {
                var c = await ImageFeatureDetector.detectRectangles(_filePath);
                setState(() {
                  _contour = c;
                });
              } on PlatformException {
                print("error happened");
              }
            }),
      ),
    );
  }
}
