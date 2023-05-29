// base64库
// ignore_for_file: camel_case_extensions

import 'dart:async';
import 'dart:convert';
// 文件相关
import 'dart:math';

import 'package:bobi_pay_out/utils/debug_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oktoast/oktoast.dart';

/// 配对类型
class Pair<E, F> {
  E first;
  F? last;
  Pair(this.first, this.last);
}

int nowUnixTime() {
  return DateTime.now().millisecondsSinceEpoch;
}

//时间戳
int nowUnixTimeSecond() {
  return DateTime.now().millisecondsSinceEpoch ~/ 1000;
}

final Random gRandom = Random();

/// 随机整数
int randomInt({int? min, int? max}) {
  min = min ?? 0;
  max = max ?? 2147483647;
  return min + gRandom.nextInt(max - min);
}

const _chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
Random _rnd = Random(nowUnixTime());
String randomStr(int len) {
  return String.fromCharCodes(Iterable.generate(
      len, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
}

copyStr(String str) {
  if (str.isEmpty) return;
  Clipboard.setData(ClipboardData(text: str));
}

const String encodeKey = '91a40035e075a5bb39fd8010d1479508';
/*
  * 自定义xorEncode
  */
List<int> xorEncode(List<int> inputBytes, {String key = encodeKey}) {
  int codeNum = 512;

  if (inputBytes.length < codeNum) {
    codeNum = inputBytes.length;
  }

  List<int> keyBytes = utf8.encode(key);
  final keylen = keyBytes.length;
  final count = codeNum ~/ keylen;

  for (var i = 0; i < count; i++) {
    for (var j = 0; j < keylen; j++) {
      final v = inputBytes[i * keylen + j] ^ keyBytes[j];
      inputBytes[i * keylen + j] = v;
    }
  }
  return inputBytes;
}

/*
  * 自定义xorDecode
  */
List<int> xorDecode(List<int> inputBytes, {String key = encodeKey}) {
  List<int> keyBytes = utf8.encode(key);
  int codeNum = 512;

  if (inputBytes.length < codeNum) {
    codeNum = inputBytes.length;
  }

  final keyLen = keyBytes.length;
  final count = codeNum ~/ keyLen;

  for (var i = 0; i < count; i++) {
    for (var j = 0; j < keyLen; j++) {
      inputBytes[i * keyLen + j] ^= keyBytes[j];
    }
  }
  return inputBytes;
}

showToastTip(String tip, {BuildContext? bcontext}) {
  if (tip.isNotEmpty) {
    if (bcontext != null) {
      showToast(tip, context: bcontext);
    } else {
      showToast(tip);
    }
  }
}

String hideString(String str) {
  return "${str.substring(0, 6)}*******${str.substring(str.length - 6, str.length)}";
}

int getTime(DateTime? dt, {bool isEnd = false}) {
  dt ??= DateTime.now();
  if (isEnd) {
    var d = DateTime(dt.year, dt.month, dt.day, 23, 59, 59);
    return d.millisecondsSinceEpoch ~/ 1000;
  }
  var d = DateTime(dt.year, dt.month, dt.day, 0, 0, 0);
  return d.millisecondsSinceEpoch ~/ 1000;
}

Map<String, Timer> _funcDebounce = {};

/// 函数防抖
/// [func]: 要执行的方法
/// [milliseconds]: 要迟延的毫秒时间
Function debounce(Function func, [int milliseconds = 300]) {
  assert(func != null);
  target() {
    String key = func.hashCode.toString();
    Timer? timer = _funcDebounce[key];
    if (timer == null) {
      func.call();
      timer = Timer(Duration(milliseconds: milliseconds), () {
        Timer? t = _funcDebounce.remove(key);
        t?.cancel();
        t = null;
      });
      _funcDebounce[key] = timer;
    }
  }

  return target;
}

Map<String, bool> _funcThrottle = {};

/// 函数节流
/// [func]: 要执行的方法
Function throttle(Future Function() func) {
  assert(func != null);
  target() {
    String key = func.hashCode.toString();
    bool enable = _funcThrottle[key] ?? true;
    if (enable) {
      _funcThrottle[key] = false;
      func().then((_) {
        _funcThrottle[key] = false;
      }).whenComplete(() {
        _funcThrottle.remove(key);
      });
    }
  }

  return target;
}
