import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';

class PersistentTabControllerService extends ChangeNotifier {
  late PersistentTabController _controller;
   int _lastIndex = 0;

  PersistentTabController get controller => _controller;
  int get lastIndex => _lastIndex;

  void setController(PersistentTabController controller) {
    _controller = controller;
    _lastIndex = controller.index;
    notifyListeners();
  }

  void setIndex(value){
    _lastIndex = value;
    notifyListeners();
  }
}
