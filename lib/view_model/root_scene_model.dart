//import 'dart:async';

// ignore_for_file: constant_identifier_names

import 'package:flutter/foundation.dart';
import 'package:bobi_pay_out/utils/string.dart';

import '../utils/event_bus.dart';

enum RootScenePage {
  ///首页
  Dizhi,

  ChuKuan,

  GuiJi,

  TongJi,

  Wode,
}

class RootSceneModel with ChangeNotifier {
  ///当前 选中的导航页
  RootScenePage _currentPage = RootScenePage.Dizhi;
  RootScenePage get currentPage => _currentPage;
  set currentPage(RootScenePage tab) {
    if (_currentPage == tab) return;
    _currentPage = tab;
    notifyListeners();
  }

  RootSceneModel() {
    ///监听返回前台事件
    eventBus.on(EventEnums.resumed, _onResumed);
    eventBus.on(EventEnums.paused, _onPaused);
  }

  @override
  void dispose() {
    eventBus.off(EventEnums.resumed, _onResumed);
    eventBus.off(EventEnums.paused, _onPaused);
    super.dispose();
  }

  void _onResumed(arg) {}

  void _onPaused(arg) {}
}
