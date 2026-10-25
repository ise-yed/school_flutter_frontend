import 'package:flutter/material.dart';

class UnfocusOnRouteChange extends NavigatorObserver {
  void _clearAfterFrame() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusManager.instance.primaryFocus?.unfocus();
    });
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    _clearAfterFrame();
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    _clearAfterFrame();
    super.didPop(route, previousRoute);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    _clearAfterFrame();
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    _clearAfterFrame();
    super.didRemove(route, previousRoute);
  }
}
