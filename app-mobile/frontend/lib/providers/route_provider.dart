import 'package:flutter/material.dart';

class RouteProvider with ChangeNotifier {
  String _currentRoute = '/';

  String get currentRoute => _currentRoute;

  void changeRoute(String newRoute) {
    _currentRoute = newRoute;
    notifyListeners();
  }
}
