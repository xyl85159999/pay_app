//订阅者回调签名
import 'dart:async';
import 'dart:collection';

typedef EventCallback<T> = void Function(T arg);

/// 生成一个遍历函数
Function makeEveryFunc<T>(f) {
  return (ls) {
    ls.forEach((el) {
      f(el);
    });
  };
}

class _AsyncEvent {
  static final Queue<_AsyncEvent> _pool = Queue<_AsyncEvent>();

  static _AsyncEvent fetch(eventName, [arg]) {
    _AsyncEvent obj = _pool.isNotEmpty ? _pool.removeLast() : _AsyncEvent();
    obj.name = eventName;
    obj.arg = arg;
    return obj;
  }

  static _AsyncEvent? discard(_AsyncEvent obj) {
    obj.arg = null;
    _pool.addLast(obj);
    return null;
  }

  /// 事件名称
  String? name;

  /// 事件参数
  dynamic arg;
}

/// 事件分发管理器
class EventBus {
  //私有构造函数
  EventBus._internal();

  //保存单例
  static final EventBus _singleton = EventBus._internal();

  //工厂构造函数
  factory EventBus() => _singleton;

  //保存事件订阅者队列，key:事件名(id)，value: 对应事件的订阅者队列
  final _emap = <Object, List<EventCallback>?>{};

  //异步触发事件队列
  final List<_AsyncEvent> _asyncEvents = [];
  //异步事件
  Timer? _asyncEventsTimer;

  //添加订阅者
  void on(String eventName, EventCallback f) {
    // mypdebug('on:' + eventName);
    // ignore: unnecessary_null_comparison
    if (eventName == null || f == null) return;
    _emap[eventName] ??= [];
    _emap[eventName]!.add(f);

    assert(_emap[eventName]!.contains(f));
  }

  // 清空所有的事件所头开始
  void clear() {
    _emap.clear();
  }

  //移除订阅者
  void off(eventName, [EventCallback? f]) {
    // mypdebug('off:' + eventName);
    var list = _emap[eventName];
    if (eventName == null || list == null) return;
    if (f == null) {
      _emap[eventName] = null;
    } else {
      list.remove(f);
    }
  }

  //触发事件，事件触发后该事件所有订阅者会被调用
  void emit(eventName, [arg]) {
    // mypdebug('emit:$eventName, arg:$arg');
    var list = _emap[eventName];
    if (list == null) return;
    int len = list.length - 1;
    //反向遍历，防止在订阅者在回调中移除自身带来的下标错位
    for (var i = len; i > -1; --i) {
      try {
        list[i](arg);
      } catch (e) {
        // debugInfo.printErrorStack(CrashType.CrashTypeClient, e, s);
      }
    }
  }

  //获取当前事件名字状态‘
  checkEvent(eventName) {
    return _emap.containsKey(eventName);
  }

  /// 异步触发事件, 相同周期内只会触发一次
  void asyncEmit(eventName, [arg]) {
    _asyncEventsTimer ??= Timer.periodic(
        const Duration(milliseconds: 500), (timer) => activate());

    for (var item in _asyncEvents) {
      // 如果已经存在队列就不触发了
      if (item.name == eventName && item.arg == arg) {
        return;
      }
    }
    _asyncEvents.add(_AsyncEvent.fetch(eventName, arg));
  }

  /// 事件管理器心跳,用于触发异步事件
  void activate() {
    while (_asyncEvents.isNotEmpty) {
      var ev = _asyncEvents.first;
      try {
        emit(ev.name, ev.arg);
      } catch (e) {
        // debugInfo.printErrorStack(CrashType.CrashTypeClient, e, null,
        //     titleInfo: "EventBusError${ev.name},${ev.arg}");
      }
      _asyncEvents.removeAt(0);
      _AsyncEvent.discard(ev);
    }
  }

  /// 对rowobject进行监听
  Map<String, EventCallback?> onTable(String tableName, EventCallback? fu,
      EventCallback? fr, EventCallback? fd) {
    if (fu != null) on('u:$tableName', fu);
    if (fr != null) on('r:$tableName', fr);
    if (fd != null) on('d:$tableName', fd);
    return {'u': fu, 'r': fr!, 'd': fd};
  }

  /// 移除rowobject的监听
  void offTable(String tableName, Map<String, EventCallback?> callbackMap) {
    if (callbackMap['u'] != null) off('u:$tableName', callbackMap['u']);
    if (callbackMap['r'] != null) off('r:$tableName', callbackMap['r']);
    if (callbackMap['d'] != null) off('d:$tableName', callbackMap['d']);
  }
}

//定义一个top-level变量，页面引入该文件后可以直接使用bus
final eventBus = EventBus();
