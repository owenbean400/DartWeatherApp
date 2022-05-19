import 'package:flutter/material.dart';
// import 'package:bitsdojo_window/bitsdojo_window.dart';

const borderColor = Color.fromARGB(100, 0, 170, 237);
const backgroundStartColor = Color.fromARGB(255, 0, 170, 237);
const backgroundEndColor = Color.fromARGB(255, 0, 145, 202);
const whiteColor = Color.fromARGB(255, 255, 255, 255);
const darkWhiteColor = Color.fromARGB(100, 255, 255, 255);
const blackColor = Color.fromARGB(255, 0, 0, 0);
const shadowColor = Color.fromARGB(30, 0, 0, 0);
const yellowColor = Color.fromARGB(255, 255, 255, 0);
const sunnyColor = Color.fromARGB(255, 255, 255, 0);
const fogColor = Color.fromARGB(255, 210, 210, 210);
const cloudColor = Color.fromARGB(255, 100, 100, 100);
const rainColor = Color.fromARGB(255, 55, 33, 255);
const clearColor = rainColor;

Map<String, ColorTile> weatherColorMap = {
  "sun": const ColorTile(Color.fromARGB(255, 255, 255, 0), blackColor),
  "clear": const ColorTile(backgroundStartColor, whiteColor),
  "fog": const ColorTile(Color.fromARGB(255, 210, 210, 210), blackColor),
  "cloud": const ColorTile(Color.fromARGB(255, 180, 180, 180), whiteColor),
  "thund": const ColorTile(Color.fromARGB(255, 12, 0, 120), whiteColor),
  "rain": const ColorTile(Color.fromARGB(255, 55, 33, 255), whiteColor),
  "snow": const ColorTile(whiteColor, blackColor)
};

Map<String, double> weatherColorMapAlpha = {
  "part": 0.8,
  "most": 0.9,
};

/*
final buttonColors = WindowButtonColors(
    iconNormal: const Color.fromARGB(255, 0, 0, 200),
    mouseOver: const Color.fromARGB(255, 0, 225, 255),
    mouseDown: const Color.fromARGB(255, 0, 0, 200),
    iconMouseOver: const Color.fromARGB(255, 0, 0, 200),
    iconMouseDown: const Color.fromARGB(255, 0, 225, 255));

final closeButtonColors = WindowButtonColors(
    mouseOver: const Color(0xFFD32F2F),
    mouseDown: const Color(0xFFB71C1C),
    iconNormal: const Color(0xFF805306),
    iconMouseOver: Colors.white);

class WindowButtons extends StatelessWidget {
  const WindowButtons({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        MinimizeWindowButton(colors: buttonColors),
        MaximizeWindowButton(colors: buttonColors),
        CloseWindowButton(colors: closeButtonColors),
      ],
    );
  }
}
*/

class ColorTile {
  final Color bgColor;
  final Color textColor;

  const ColorTile(this.bgColor, this.textColor);
}
