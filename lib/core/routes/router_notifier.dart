import 'package:flutter/foundation.dart';

class RouterNotifier extends ChangeNotifier {
  void notify() {
    notifyListeners();
  }
}
