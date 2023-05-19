import 'package:flutter/material.dart';
import 'package:bobi_pay_out/manager/config_mgr.dart';

class ConfigModel extends ChangeNotifier {
  List<ConfData> _list = [];
  List<ConfData> get list {
    return _list;
  }

  set list(List<ConfData> list) {
    _list = list;
    notifyListeners();
  }
}
