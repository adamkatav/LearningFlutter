import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ftpconnect/ftpconnect.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hello',
      theme: ThemeData(
        primarySwatch: Colors.amber,
      ),
      home: const MyHomePage(title: 'Adam\'s homework'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Image? _chosenImage;
  File? _chosenImageFile;
  TextEditingController textEditingController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: ListView(
          //mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
              ElevatedButton(
                  onPressed: () => chooseImage(ImageSource.gallery),
                  child: const Text('Choose Image')),
              ElevatedButton(
                onPressed: () => chooseImage(ImageSource.camera),
                child: const Text('Take picture'),
              )
            ]),
            Row(
              children: <Widget>[
                Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: textEditingController,
                      decoration: const InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: 'FTP server IP'),
                    )),
                ElevatedButton(
                    onPressed: sendImage, child: const Text('Send image!'))
              ],
            ),
            currentImage,
          ],
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Image get currentImage {
    return _chosenImage ?? Image.asset('assets/images/head.png');
  }

  File get currentFile {
    return _chosenImageFile ?? File('EMPTY FILE');
  }

  void chooseImage(var source) async {
    //await Permission.camera.request();
    final ImagePicker _picker = ImagePicker();
    if (source == ImageSource.gallery ||
        await Permission.camera.request().isGranted) {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        _chosenImage = Image.file(File(image.path));
        _chosenImageFile = File(image.path);
      }
    }
    setState(() {});
  }

  void sendImage() async {
    FTPConnect ftpConnect =
        FTPConnect(textEditingController.text, user: 'adam', pass: '318758489');
    try {
      await ftpConnect.connect();
      await ftpConnect.uploadFile(currentFile);
      await ftpConnect.disconnect();
    } catch (e) {
      AlertDialog alert = AlertDialog(
        title: const Text("Error!"),
        content: Text(e.toString()),
        actions: [
          TextButton(
            child: const Text("OK"),
            onPressed: () {},
          ),
        ],
      );
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        },
      );
    }
  }
}
