import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import 'package:bobi_pay_out/utils/debug_info.dart';
import 'package:bobi_pay_out/utils/string.dart';
import 'package:bobi_pay_out/utils/utility.dart';

import '../utils/event_bus.dart';

final ConnectivityMgr connectivityMgr = ConnectivityMgr();

/// 连接状态管理, 由于socket在连接变化的时候响应不够及时,监听网络变化提示
class ConnectivityMgr {
  /// 当前的网络连接状态
  ConnectivityResult? _connectivityResult;

  /// 连接状态.
  ConnectivityResult get connectivityResult =>
      _connectivityResult ?? ConnectivityResult.wifi;
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  /// 初始化网络状态
  initConnectivityMgr() async {
    // 监听网络变化
    _connectivitySubscription ??=
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);

    ConnectivityResult? result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      mypdebug(e.toString());
    }
    // 如果连接状态有变化的时候要记录下来
    if (_connectivityResult == null) {
      _connectivityResult = result;
      return;
    }
    _updateConnectionStatus(result!);
  }

  int _onResumed = 1;
  int? _onPausedTime;

  /// 回到前台
  onResumed(ary) async {
    _onResumed++;

    try {
      // 如果是ios超过10s强制重启
      _onPausedTime ??= nowUnixTimeSecond();
      bool isForce = (_onPausedTime! + 10 < nowUnixTimeSecond());
      if (_connectivityResult == ConnectivityResult.none || isForce) {
        ConnectivityResult? result;
        try {
          result = await _connectivity.checkConnectivity();
        } on PlatformException catch (e) {
          mypdebug(e.toString());
        }
        // 如果连接状态有变化的时候要记录下来
        if (_connectivityResult == null) {
          _connectivityResult = result;
          return;
        }
        _updateConnectionStatus(result!);
      }
    } catch (e) {
      mypdebug("onResumed");
    }
  }

  onPaused(ary) async {
    _onResumed--;
    // 记录一下，切后台时间
    _onPausedTime ??= nowUnixTimeSecond();

    // 如果不是主播端,切后台马上...
    await Future.delayed(const Duration(seconds: 8));
    mypdebug("切后台延迟关闭:$_onResumed");
    if (_onResumed <= 0) {
      mypdebug("超过8秒关闭连接:$_onResumed");
    }
  }

  /// 释放所有资源
  void dispose() {
    _connectivitySubscription!.cancel();
    eventBus.off(EventEnums.resumed, onResumed);
    // eventBus.off(EventEnums.resumed, _onPaused);
  }

  Future<void> _updateConnectionStatus(ConnectivityResult newStatus) async {
    switch (newStatus) {
      case ConnectivityResult.none:
        mypdebug('连接状态变化:无');
        break;
      case ConnectivityResult.mobile:
        mypdebug('连接状态变化:移动网络');
        break;
      case ConnectivityResult.wifi:
        mypdebug('连接状态变化:WIFI');
        break;
      case ConnectivityResult.bluetooth:
        break;
      case ConnectivityResult.ethernet:
        break;
      case ConnectivityResult.vpn:
        break;
      case ConnectivityResult.other:
        // TODO: Handle this case.
        break;
    }

    // 触发一下所有的状态变化
    var oldStatus = _connectivityResult;
    // 保存一下连接状态
    _connectivityResult = newStatus;
    eventBus.emit(EventEnums.connectivityChanged, _connectivityResult);

    // 如果连接发生变化并且网络是由 有到无
    const none = ConnectivityResult.none;
    if (oldStatus != newStatus) {
      // 从有到无
      if (oldStatus != none && newStatus == none) {
        // await _closeWebScoket("_updateConnectionStatus");
      }

      // 从无到有
      if (oldStatus == none && newStatus != none) {
        mypdebug("网络从无到有,启动重连");
      }

      //网络有变化都检测一下
      Future.delayed(const Duration(seconds: 2)).then(onResumed);
    }
  }
}
