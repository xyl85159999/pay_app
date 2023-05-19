// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:bobi_pay_out/manager/addr_mgr.dart';
import 'package:bobi_pay_out/service/service_voss_tj.dart';

DiZhiBalanceModel dizhi_balance_model = DiZhiBalanceModel();

class DiZhiBalanceModel extends ChangeNotifier {
  double? _usdt_balance;
  get usdt_balance => _usdt_balance ?? 0;

  bool _isLock = false;
  query_balance() async {
    String? fromBagName = dizhi_bagname_model.select_books_name;
    if (fromBagName == null || fromBagName.isEmpty) return;
    if (_isLock) return;
    _isLock = true;
    final balance = await serviceVossTj.get_amount(fromBagName);
    _isLock = false;
    if (balance == null || balance == _usdt_balance) return;
    _usdt_balance = balance * 1.0;
    notifyListeners();
  }
}
