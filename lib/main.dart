import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_qr_reader/flutter_qr_reader.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(MaterialApp(home: MyApp()));

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with SingleTickerProviderStateMixin {
  String data;
  File image;
  final _key = new GlobalKey<ScaffoldState>();

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/image.png';
  }

  Future<File> saveImage(File image) async {
    final savedImage = await image.copy(await _localPath);
    return savedImage;
  }

  Future<void> loadImage() async {
    try {
      final path = await _localPath;
      final file = File(path);
      final exists = await file.exists();
      if (exists) {
        image = file;
        data = await FlutterQrReader.imgScan(image.path);
      }
      setState(() {});
    } catch (e) {
      image = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      body: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          DottedBorder(
            borderType: BorderType.RRect,
            radius: Radius.circular(4),
            child: Container(
                width: 300,
                height: 300,
                child: image == null
                    ? TextButton(
                        child: Text(
                          "Загрузить",
                          style: TextStyle(fontSize: 20),
                        ),
                        onPressed: () async {
                          final _image = await ImagePicker().pickImage(source: ImageSource.gallery);
                          image = File(_image.path);
                          data = await FlutterQrReader.imgScan(image.path);
                          saveImage(image);
                          setState(() {});
                        },
                      )
                    : GestureDetector(
                        onTap: () => showModalBottomSheet(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20), topRight: Radius.circular(20))),
                          context: context,
                          builder: (context) => Container(
                            alignment: Alignment.center,
                            height: 50,
                            child: TextButton(
                              onPressed: () {
                                image = null;
                                data = null;
                                Navigator.of(context).pop();
                                setState(() {});
                              },
                              child: Text(
                                "Удалить",
                                style: TextStyle(fontSize: 20),
                              ),
                            ),
                          ),
                        ),
                        child: Image.file(
                          image,
                          fit: BoxFit.cover,
                        ),
                      )),
          ),
          if (data != null)
            TextButton(
                child: Text(
                  "Проверить",
                  style: TextStyle(fontSize: 20),
                ),
                onPressed: () async {
                  if (await canLaunch(data)) {
                    await launch(data);
                  }
                })
        ]),
      ),
    );
  }
}

class Info extends StatelessWidget {
  Widget build(BuildContext context) {
    return Container();
  }
}
