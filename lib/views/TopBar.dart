import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';

const borderColor = Color.fromARGB(100, 0, 170, 237);
const backgroundStartColor = Color.fromARGB(255, 0, 170, 237);
const backgroundEndColor = Color.fromARGB(255, 0, 145, 202);

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