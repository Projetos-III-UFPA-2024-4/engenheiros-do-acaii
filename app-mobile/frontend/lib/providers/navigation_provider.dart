import 'package:flutter/material.dart';

class NavigationProvider with ChangeNotifier {
  int _selectedIndex = 0;

  int get selectedIndex => _selectedIndex;

  void changePage(int index) {
    _selectedIndex = index;
    notifyListeners();
  }
}
