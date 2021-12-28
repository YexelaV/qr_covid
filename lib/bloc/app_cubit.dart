import 'package:bloc/bloc.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_qr_reader/flutter_qr_reader.dart';
import 'package:image_picker/image_picker.dart';

part 'app_state.dart';

const qrFilename = 'image.png';
const documentFilename = 'document.png';

class AppCubit extends Cubit<AppState> {
  AppCubit() : super(AppInitial());

  File image;
  File document;
  String link;

  Future<void> loadFromCache() async {
    emit(AppLoading());
    image = await loadImage(qrFilename);
    document = await loadImage(documentFilename);
    var link;
    if (image != null) {
      link = await FlutterQrReader.imgScan(image.path);
    }
    emit(AppReady(image: image, document: document, link: link));
  }

  Future<String> getPath(String filename) async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/$filename';
  }

  Future<void> loadFromGallery(String filename) async {
    final _image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (_image != null) {
      final result = File(_image.path);
      await result.copy(await getPath(filename));
      if (filename == qrFilename) {
        image = result;
        link = await FlutterQrReader.imgScan(result.path);
      } else {
        document = result;
      }
      emit(AppReady(image: image, document: document, link: link));
    }
  }

  Future<File> loadImage(String filename) async {
    try {
      final path = await getPath(filename);
      final file = File(path);
      if (await file.exists()) {
        return file;
      }
    } catch (e) {}
    return null;
  }

  Future<void> deleteImage(String filename) async {
    final file = File(await getPath(filename));
    if (await file.exists()) {
      await file.delete();
    }
    if (filename == qrFilename) {
      image = null;
      link = null;
    } else {
      document = null;
    }
    emit(AppReady(image: image, document: document, link: link));
  }
}
