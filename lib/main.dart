import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:url_launcher/url_launcher.dart';
import 'bloc/app_cubit.dart';

void main() => runApp(MaterialApp(home: App()));

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> with SingleTickerProviderStateMixin {
  String data;
  File image;
  AppCubit appCubit;

  @override
  void initState() {
    super.initState();
    appCubit = AppCubit()..loadFromCache();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: BlocBuilder<AppCubit, AppState>(
            bloc: appCubit,
            builder: (context, state) {
              if (state is AppLoading) {
                return Center(
                  child: SizedBox(
                    width: 50,
                    height: 50,
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              if (state is AppReady) {
                image = state.image;
                data = state.link;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DottedBorder(
                        borderType: BorderType.RRect,
                        radius: Radius.circular(4),
                        child: Container(
                          width: 300,
                          height: 300,
                          child: image == null
                              ? TextButton(
                                  child: Text(
                                    "Загрузить QR-код",
                                    style: TextStyle(fontSize: 20),
                                  ),
                                  onPressed: () async {
                                    await appCubit.loadFromGallery();
                                    setState(() {});
                                  },
                                )
                              : GestureDetector(
                                  onTap: () => showModalBottomSheet(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(20),
                                            topRight: Radius.circular(20))),
                                    context: context,
                                    builder: (context) => Container(
                                      alignment: Alignment.center,
                                      height: 50,
                                      child: TextButton(
                                        onPressed: () async {
                                          await showDialog(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: Text(
                                                "Удалить изображение?",
                                                style: TextStyle(fontSize: 20),
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () async {
                                                    await appCubit.deleteImage();
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: Text("OК"),
                                                ),
                                                TextButton(
                                                  onPressed: () => Navigator.of(context).pop(),
                                                  child: Text("Отмена"),
                                                )
                                              ],
                                            ),
                                          );
                                          Navigator.of(context).pop();
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
                                ),
                        )),
                    if (data != null)
                      TextButton(
                          child: Text(
                            "Открыть",
                            style: TextStyle(fontSize: 20),
                          ),
                          onPressed: () async {
                            if (await canLaunch(data)) {
                              await launch(data);
                            } else {
                              await showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text(
                                    "Не удалось открыть QR-код",
                                    style: TextStyle(fontSize: 20),
                                  ),
                                  actions: [
                                    TextButton(
                                        onPressed: Navigator.of(context).pop, child: Text("OK"))
                                  ],
                                ),
                              );
                            }
                          })
                  ],
                );
              }
              return Container();
            }),
      ),
    );
  }
}
