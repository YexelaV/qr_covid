import 'package:bloc/bloc.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_qr_reader/flutter_qr_reader.dart';
import 'package:image_picker/image_picker.dart';

part 'app_state.dart';

class AppCubit extends Cubit<AppState> {
  AppCubit() : super(AppInitial());

  Future<void> loadFromCache() async {
    emit(AppLoading());
    final image = await loadImage();
    var link;
    if (image != null) {
      link = await FlutterQrReader.imgScan(image.path);
    }
    emit(AppReady(image: image, link: link));
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/image.png';
  }

  Future<void> loadFromGallery() async {
    final _image = await ImagePicker().pickImage(source: ImageSource.gallery);
    final image = File(_image.path);
    await image.copy(await _localPath);
    final link = await FlutterQrReader.imgScan(image.path);
    emit(AppReady(image: image, link: link));
  }

  Future<File> loadImage() async {
    try {
      final path = await _localPath;
      final file = File(path);
      if (await file.exists()) {
        return file;
      }
    } catch (e) {}
    return null;
  }

  Future<void> deleteImage() async {
    final path = await _localPath;
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
    emit(AppReady());
  }
}
