import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:photo_view/photo_view.dart';
import 'package:url_launcher/url_launcher.dart';
import 'bloc/app_cubit.dart';

void main() => runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      home: App(),
    ));

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> with SingleTickerProviderStateMixin {
  String data;
  File image;
  File document;
  AppCubit appCubit;
  TabController tabController;

  @override
  void initState() {
    super.initState();
    appCubit = AppCubit()..loadFromCache();
    tabController = TabController(vsync: this, initialIndex: 0, length: 2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Center(
          child: Text(
            "Ваш QR-код вакцинации",
            style: TextStyle(color: Colors.black),
          ),
        ),
      ),
      body: BlocBuilder<AppCubit, AppState>(
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
              document = state.document;
              return Column(
                children: [
                  TabBar(
                    controller: tabController,
                    indicatorWeight: 2.0,
                    //  indicatorColor: Colors.black.withOpacity(0.5),
                    tabs: [
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          "Сертификат",
                          style: TextStyle(color: Colors.black, fontSize: 16.0),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child:
                            Text("Документ", style: TextStyle(color: Colors.black, fontSize: 16.0)),
                      )
                    ],
                  ),
                  Expanded(
                    child: TabBarView(controller: tabController, children: [
                      Center(
                        child: Column(
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
                                            await appCubit.loadFromGallery(qrFilename);
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
                                                            await appCubit.deleteImage(qrFilename);
                                                            Navigator.of(context).pop();
                                                          },
                                                          child: Text("OК"),
                                                        ),
                                                        TextButton(
                                                          onPressed: () =>
                                                              Navigator.of(context).pop(),
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
                              Padding(
                                padding: const EdgeInsets.only(top: 16.0),
                                child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8.0),
                                      ),
                                    ),
                                    child: Text(
                                      "Открыть сертификат",
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
                                                  onPressed: Navigator.of(context).pop,
                                                  child: Text("OK"))
                                            ],
                                          ),
                                        );
                                      }
                                    }),
                              )
                          ],
                        ),
                      ),
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            DottedBorder(
                                borderType: BorderType.RRect,
                                radius: Radius.circular(4),
                                child: Container(
                                  width: 300,
                                  height: 300,
                                  child: document == null
                                      ? TextButton(
                                          child: Text(
                                            "Загрузить документ",
                                            style: TextStyle(fontSize: 20),
                                          ),
                                          onPressed: () async {
                                            await appCubit.loadFromGallery(documentFilename);
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
                                                            await appCubit
                                                                .deleteImage(documentFilename);
                                                            Navigator.of(context).pop();
                                                          },
                                                          child: Text("OК"),
                                                        ),
                                                        TextButton(
                                                          onPressed: () =>
                                                              Navigator.of(context).pop(),
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
                                            document,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                )),
                            if (document != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 16.0),
                                child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8.0),
                                      ),
                                    ),
                                    child: Text(
                                      "Развернуть документ",
                                      style: TextStyle(fontSize: 20),
                                    ),
                                    onPressed: () => Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) => View(document),
                                          ),
                                        )),
                              )
                          ],
                        ),
                      ),
                    ]),
                  )
                ],
              );
            }
            return Container();
          }),
    );
  }
}

class View extends StatelessWidget {
  final File document;
  View(this.document);
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Center(
          child: Text(
            "Ваш QR-код вакцинации",
            style: TextStyle(color: Colors.black),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: 24, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: PhotoView(
        imageProvider: FileImage(document),
        minScale: 0.1,
        maxScale: 10.0,
      ),
    );
  }
}
