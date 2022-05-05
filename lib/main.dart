import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';

import 'views/top_bar.dart';
import 'views/screen.dart';

void main() {
  runApp(const MyApp());
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
                  color: backgroundStartColor,
                  width: 1,
                  child: const MainScreen())));
    } else {
      return const MaterialApp(title: "Weather App", home: PhoneMain());
    }
  }
}

class PhoneMain extends StatefulWidget {
  const PhoneMain({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PhoneMain();
}

class _PhoneMain extends State<PhoneMain> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          child: Main(_selectedIndex)),
      bottomNavigationBar: Container(
          decoration: const BoxDecoration(boxShadow: <BoxShadow>[
            BoxShadow(
                color: shadowColor, blurRadius: 8.0, offset: Offset(0.0, 0.25))
          ]),
          child: BottomNavigationBar(
            elevation: 20.0,
            backgroundColor: backgroundEndColor,
            selectedItemColor: whiteColor,
            unselectedItemColor: darkWhiteColor,
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                  icon: Icon(Icons.apps_rounded), label: "Daily"),
              BottomNavigationBarItem(
                  icon: Icon(Icons.access_time_filled_rounded), label: "Hourly")
            ],
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
          )),
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({Key? key}) : super(key: key);

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
                const WindowButtons()
              ])),
              const Expanded(child: Main(1))
            ])));
  }
}
