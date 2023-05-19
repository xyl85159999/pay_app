import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:bobi_pay_out/manager/connectivity_mgr.dart';

import '../utils/event_bus.dart';
import '../utils/string.dart';

class NetStatusModel with ChangeNotifier {
  /// 是否有网络
  bool? hasNet;

  /// 与api是否连接
  bool? apiConnect;

  // 上网方式
  ConnectivityResult apiConnentState = ConnectivityResult.none;

  bool _isDisposed = false;
  bool avtive = false;

  NetStatusModel() {
    init(this);

    eventBus.on(EventEnums.connectivityChanged, _connectivityChanged);
    eventBus.on(EventEnums.resumed, init);
  }

  init(arg) {
    apiConnentState = ConnectivityResult.wifi;
    apiConnect = true;
    hasNet = true;

    // 5秒后再来显示状态
    Future.delayed(const Duration(seconds: 2), () {
      avtive = true;
      _connectivityChanged(connectivityMgr.connectivityResult);
    });
    if (arg == null) setListeners();
  }

  onLoginStatusChange(arg) {
    setListeners();
  }

  /// API的连接状态
  _connectivityChanged(arg) {
    if (!avtive) return;
    if (hasNet != (arg != ConnectivityResult.none)) {
      hasNet = (arg != ConnectivityResult.none);
      setListeners();
    }
  }

  //刷新界面
  setListeners() {
    //没有被释放的才可以响应
    if (!_isDisposed) notifyListeners();
  }

  @override
  void dispose() {
    eventBus.off(EventEnums.connectivityChanged, _connectivityChanged);
    eventBus.off(EventEnums.resumed, init);
    _isDisposed = true;
    super.dispose();
  }
}
