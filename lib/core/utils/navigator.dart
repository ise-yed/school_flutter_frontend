import 'package:flutter/material.dart';

Future<T?> goScreen<T>({
  required BuildContext context,
  required Widget screen,
  bool closeScreen = false,
  bool closeAllScreen = false,
  bool fullScreen = false,
}) {
  final navigator = Navigator.of(context, rootNavigator: fullScreen);
  final route = MaterialPageRoute<T>(builder: (_) => screen);

  if (closeScreen) {
    return navigator.pushReplacement<T, T?>(route, result: null);
  } else if (closeAllScreen) {
    return navigator.pushAndRemoveUntil<T>(route, (_) => false);
  } else {
    return navigator.push<T>(route);
  }
}
