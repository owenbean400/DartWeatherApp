import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';

import './models/weatherAPI.dart';
import './views/TopBar.dart';
import './views/Main.dart';

void main() {
  runApp(MyApp());
  doWhenWindowReady(() {
    final win = appWindow;
    const initialSize = Size(600, 450);
    win.minSize = initialSize;
    win.size = initialSize;
    win.alignment = Alignment.center;
    win.title = "Custom window with Flutter";
    win.show();
  });
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
      return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
              body: WindowBorder(
                  color: backgroundStartColor, width: 1, child: MainScreen())));
    } else {
      return MaterialApp(
          title: "Weather App",
          home: Scaffold(
              appBar: AppBar(
                title: const Text('Owen Weather App'),
              ),
              body: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [backgroundStartColor, backgroundEndColor],
                        stops: [0.0, 1.0]),
                  ),
                  child: Main())));
    }
  }
}

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [backgroundStartColor, backgroundEndColor],
                  stops: [0.0, 1.0]),
            ),
            child: Column(children: [
              WindowTitleBarBox(
                  child: Row(children: [
                Expanded(child: MoveWindow()),
                WindowButtons()
              ])),
              Expanded(child: Main())
            ])));
  }
}
