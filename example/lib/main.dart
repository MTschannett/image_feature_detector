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
  Point _testPoint;
  TransformedImage _transfomed;

  @override
  void initState() {
    super.initState();
    initPlatformState();

    // Use the RelativeCoodrinateHelper to calculate a value for our point.
    setState(() {
      _testPoint = RelativeCoordianteHelper.calculatePointDinstances(
          Point(x: 0.05, y: 0.05), ImageDimensions(500, 500));
    });
  }

  Future<String> _loadTestImage() async {
    var directory2 = await getApplicationDocumentsDirectory();

    var path = "${directory2.path}/images/tmp1.png";

    var file = File(path);
    if (!await file.exists()) {
      var data = await rootBundle.load("images/rectangle.jpg");

      try {
        await file.create(recursive: true);
      } catch (e) {
        print(e);
      }

      file.writeAsBytes(
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
    }

    return path;
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
      var path = await _loadTestImage();

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

  void _reloadTestImage() async {
    var f = File(_filePath);

    if (f.existsSync()) {
      f.deleteSync(recursive: true);
    }

    if (!f.existsSync()) {
      var s = await _loadTestImage();

      setState(() {
        _filePath = s;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // var image = _filePath == null ? Container() : Image.file(File(_filePath));
    Column c;
    Widget image;

    if (_contour != null) {
      c = Column(
        children: _contour.contour.map((p) {
          return Text(
              "X: ${RelativeCoordianteHelper.calculateDistance(p.x, _contour.dimensions.width)}, Y: ${RelativeCoordianteHelper.calculateDistance(p.y, _contour.dimensions.height)}");
        }).toList(),
      );
    } else {
      c = Column(
        children: <Widget>[Text("No contour calculated")],
      );
    }

    if (_transfomed != null) {
      image = Image.file(File(_transfomed.filePath));
    } else {
      image = Text("Press button to get transformed image");
    }

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Text('Running on: $_platformVersion\n'),
                c,
                Text("Example RelativePointHelper using Point:"),
                Text(
                    "Calculated values: x: ${_testPoint != null ? _testPoint.x : "-"}, y: ${_testPoint != null ? _testPoint.y : "-"}"),
                FlatButton(
                  child: Text("Reload test image"),
                  onPressed: _reloadTestImage,
                ),
                image
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
            child: Icon(Icons.image),
            onPressed: () async {
              try {
                // var c = await ImageFeatureDetector.detectRectangles(_filePath);
                var transformed =
                    await ImageFeatureDetector.detectAndTransformRectangle(
                        _filePath);
                setState(() {
                  _transfomed = transformed;
                });
                // setState(() {
                //   _contour = c;
                // });
              } on PlatformException {
                print("error happened");
              }
            }),
      ),
    );
  }
}
