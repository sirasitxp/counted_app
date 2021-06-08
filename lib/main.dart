import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';
import 'package:meta/meta.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Conted'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File? _image; // Solved the issue by using ?
  final picker = ImagePicker();
  bool isImageLoaded = false;
  List? _resultList;
  String _confidence = "";
  String _name = "";

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      _image = File(pickedFile!.path);
      runModelOnImage(File(pickedFile.path));
    });
  }

  Future loadModel() async {
    var result = await Tflite.loadModel(
      model: "assets/model_unquant.tflite",
      labels: "assets/labels.txt",
    );
    print("Result after loading model: $result");
  }

  runModelOnImage(File file) async {
    var res = await Tflite.runModelOnImage(
      path: file.path,
      numResults: 2,
      threshold: 0.5,
      imageMean: 127.5,
      imageStd: 127.5,
    );

    setState(() {
      _resultList = res;
      String str = _resultList![0]["label"];
      _name = str.substring(2);
      _confidence = _resultList != null
          ? (_resultList![0]['confidence'] * 100).toString().substring(0, 2) +
              "%"
          : "";
    });
  }

  @override
  void initState() {
    super.initState();
    loadModel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          children: [
            Container(
              width: 300,
              height: 300,
              child: _image == null
                  ? Text('No image selected.')
                  : Image.file(_image!),
            ),
            Text("Name: $_name\nConfidence: $_confidence"),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: getImage,
        child: Icon(Icons.photo),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
