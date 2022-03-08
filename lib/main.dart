import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ftpconnect/ftpconnect.dart';
import 'package:path_provider/path_provider.dart';

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
  TextEditingController ipEditingController = TextEditingController();
  TextEditingController userEditingController = TextEditingController();
  TextEditingController passEditingController = TextEditingController();
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
                    flex: 1,
                    child: TextFormField(
                      controller: userEditingController,
                      decoration: const InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: 'username'),
                    )),
                Expanded(
                    flex: 1,
                    child: TextFormField(
                      controller: passEditingController,
                      decoration: const InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: 'password'),
                    ))
              ],
            ),
            Row(
              children: <Widget>[
                Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: ipEditingController,
                      decoration: const InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: 'FTP server IP'),
                    )),
                ElevatedButton(
                    onPressed: sendImage, child: const Text('Send image!')),
                ElevatedButton(
                    onPressed: downloadJson,
                    child: const Text('download test.json!'))
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
    return _chosenImage ?? Image.asset('assets/images/boar.jpg');
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

  void downloadJson() async {
    FTPConnect ftpConnect = FTPConnect(ipEditingController.text,
        user: userEditingController.text, pass: passEditingController.text);
    try {
      await Permission.storage.request();
      await ftpConnect.connect();
      String fileName = 'test.json';
      final Directory directory = await getApplicationDocumentsDirectory();
      final File file = File('${directory.path}/$fileName');
      await ftpConnect.downloadFileWithRetry(fileName, file);
      await ftpConnect.disconnect();
      AlertDialog showText = AlertDialog(
        title: const Text("Hello!"),
        content: Text(await file.readAsString()),
        actions: [
          TextButton(
            child: const Text("OK"),
            onPressed: () {
              Navigator.pop(context);
              FocusScope.of(context).requestFocus(FocusNode());
            },
          ),
        ],
      );
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return showText;
        },
      );
    } catch (e) {
      AlertDialog alert = AlertDialog(
        title: const Text("Error!"),
        content: Text(e.toString()),
        actions: [
          TextButton(
            child: const Text("OK"),
            onPressed: () {
              Navigator.pop(context);
              FocusScope.of(context).requestFocus(FocusNode());
            },
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
    FocusScope.of(context).requestFocus(FocusNode());
  }

  void sendImage() async {
    FTPConnect ftpConnect = FTPConnect(ipEditingController.text,
        user: userEditingController.text, pass: passEditingController.text);
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
            onPressed: () {
              Navigator.pop(context);
              FocusScope.of(context).requestFocus(FocusNode());
            },
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
    FocusScope.of(context).requestFocus(FocusNode());
  }
}
