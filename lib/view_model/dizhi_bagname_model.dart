// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:bobi_pay_out/model/update_block_bean.dart';
import 'package:bobi_pay_out/service/service_voss_tj.dart';
import 'package:bobi_pay_out/view_model/dizhi_balance_model.dart';

class DiZhiBagNameModel extends ChangeNotifier {
  List _listBagName = [];
  List _listSelectBagName = [];
  List get listBagName => _listBagName;
  List get listWalletTypeBagName => [
        '',
        'wallet_trx',
        'wallet_eth',
      ];
  List get listSelectBagName => _listSelectBagName;
  String? _select_books_name = '';
  get select_books_name => _select_books_name;
  set select_books_name(v) {
    _select_books_name = v;
    notifyListeners();
    dizhi_balance_model.query_balance();
  }

  String? _selectWalletType = '';
  get selectWalletType => _selectWalletType;
  set selectWalletType(v) {
    _select_books_name = '';
    _selectWalletType = v;
    sort_bagName();
    notifyListeners();
  }

  DiZhiBagNameModel() {
    init();
  }

  sort_bagName() {
    _listSelectBagName = [
      {'books_name': ''}
    ];
    if (_selectWalletType == null || _selectWalletType!.isEmpty) return;
    for (var bagName in _listBagName) {
      if (bagName['wallet_type'] == _selectWalletType) {
        _listSelectBagName.add(bagName);
      }
    }
  }

  init() async {
    // final list = await serviceVossTj.getBagNameList();
    // _listBagName = list;
    HttpResponseBean res = await serviceVossTj.getBagNameList();
    _listBagName = res.result;
    if (_listBagName.isNotEmpty) {
      _listSelectBagName.clear();
      sort_bagName();
    }
    notifyListeners();
  }
}
