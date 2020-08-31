import 'package:flutter/widgets.dart';
import 'package:resurgence/family/family.dart';

class FamilyState extends ChangeNotifier {
  Family _family;

  set family(Family value) {
    _family = value;
    notifyListeners();
  }

  Family get family => _family;

  String get name => _family?.name;

  bool get haveFamily => _family != null;
}
