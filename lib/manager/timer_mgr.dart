// ignore_for_file: depend_on_referenced_packages, constant_identifier_names, non_constant_identifier_names

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:synchronized/synchronized.dart' as synchronized;
import 'package:bobi_pay_out/utils/debug_info.dart';
import 'package:bobi_pay_out/utils/utility.dart';

final TimerMgr timer_mgr = TimerMgr();

/// 支持心跳接口
abstract class OnUpdateActor {
  Future<void> updateTick(int diff);
  @protected
  mypdebug(dynamic msg, {bool writeSentry = true, int len = OUTPUT_LEN}) {
    String outMsg = '[$runtimeType] 9527 $msg';
    pdebug(outMsg, writeSentry: writeSentry, len: len);
  }
}

/// 自定义心跳记数器
class TickHolder {
  /// 当前心跳的时间ms数
  int _i = 0;

  /// 每次触发的毫秒数
  int _timer;

  int get timer => _timer;

  TickHolder(this._timer);

  /// 增加超时时间
  void add(int v, {int? max}) {
    _timer += v;
    if (max != null && _timer > max) {
      _timer = max;
    }
  }

  /// 重新设置周期时间
  void init(int v) {
    _timer = v;
  }

  /// 心跳自增加
  bool update(int diff) {
    _i = _i + diff;
    if (_i >= _timer) {
      // _i -= _timer;
      _i = 0; //还是从头开始吧,万一有脏数据就坏了
      return true;
    }
    return false;
  }

  /// 重置定时器值
  void reset({timer}) {
    if (timer) {
      _timer = timer;
    }
    _i = 0;
  }
}

/// 自定义心跳管理器
final TimerMgr timerMgr = TimerMgr();

/// 每帧变化的时间
const _UpdateMs = 100;

/// 本地时间管理
class TimerMgr {
  int _lastTime = 0;
  int _curTime = 0;

  /// 当前所有的待更新队列
  final Set<Pair<TickHolder, OnUpdateActor>> _list = {};

  /// 待加入队列
  final List<Pair<TickHolder, OnUpdateActor>> _addList = [];

  /// 待删除队列
  final List<OnUpdateActor> _delList = [];

  TimerMgr() {
    _curTime = _now();
    _lastTime = _curTime;

    __createTimer();
  }

  int _now() {
    return DateTime.now().millisecondsSinceEpoch;
  }

  void add(OnUpdateActor a, {int? ms}) {
    _addList.add(Pair(TickHolder(ms ?? _UpdateMs), a));
  }

  /// 增加可以心跳的东西
  void del(OnUpdateActor b) {
    _delList.add(b);
  }

  Timer? _timer;
  __createTimer() {
    if (_timer == null) {
      synchronized.Lock lock = synchronized.Lock();
      bool isUpdating = false;
      _timer = Timer.periodic(const Duration(milliseconds: _UpdateMs),
          (timer) async {
        await lock.synchronized(() async {
          assert(!isUpdating);
          isUpdating = true;

          await updateTick(_UpdateMs);

          // 如果没有东西需要跳了，停止心跳
          if (_list.isEmpty && _addList.isEmpty) {
            timer.cancel();
            _timer = null;
          }
          isUpdating = false;
        });
      });
    }
  }

  /// 心跳啊，心跳
  Future<void> updateTick(diff) async {
    int now = _now();
    int diff = now - _lastTime;
    if (diff > 0) {
      for (var item in _list) {
        // 每个管理器的心跳帧率可能不一致,使用定时器
        if (item.first.update(diff)) {
          await item.last?.updateTick(item.first.timer);
        }
      }
    }
    _lastTime = now;

    // 待加入的队列
    _list.addAll(_addList);
    _addList.clear();

    for (var i = 0; i < _delList.length; i++) {
      var todel = _delList[i];
      _list.remove(todel);
    }
    _delList.clear();
  }
}
