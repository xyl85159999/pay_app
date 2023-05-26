// ignore_for_file: constant_identifier_names, prefer_typing_uninitialized_variables

import 'dart:io';

import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:bobi_pay_out/utils/debug_info.dart';
import 'package:bobi_pay_out/utils/route/router_handler.dart';
import 'package:bobi_pay_out/utils/utility.dart';

class Routes {
// 路由管理
  static FluroRouter? router;
  static const String rootScene = '/';
  //统计详情
  static const String tongjiDetail = '/tongjiDetail';
  //关闭自身页面
  static const String JUMP_CloseSelf = 'close_self';

  //获取上一次请求的
  static var _oldTimer;
  static var _oldPath;
  static var _oldParms;

  static void configureRoutes(FluroRouter router) {
    router.notFoundHandler = Handler(
        handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
      pdebug('route not found!');
      return null;
    });

    router.define(rootScene, handler: rootSceneHandler);

    _confgOpenTransition();
  }

  static List<String>? _transitionDic;
  //配置需要抽屉打开页面。加入队列中对象必须打开
  static _confgOpenTransition() {
    _transitionDic = [Routes.tongjiDetail];
  }

  static TransitionType _getOpenTransitionByNmae(
      String val, TransitionType transition) {
    if (!_transitionDic!.contains(val)) {
      return transition;
    } else {
      return TransitionType.native;
    }
  }

  //通用关闭弹窗
  static void popPage(BuildContext context) {
    // Navigator.of(context).maybePop();
    Navigator.canPop(context) ? Navigator.pop(context) : null;
  }

  // 对参数进行encode，解决参数中有特殊字符，影响fluro路由匹配(https://www.jianshu.com/p/e575787d173c)
  static Future? navigateTo(BuildContext? context, String path,
      {Map<String, dynamic>? params,
      bool clearStack = false,
      TransitionType transition = TransitionType.inFromRight,
      bool replace = false}) {
    if (context == null) return null;
    if (_oldTimer != null &&
        nowUnixTimeSecond() - _oldTimer < 1 &&
        _oldPath != null &&
        _oldPath == path &&
        _oldParms == params.toString()) {
      return null;
    } else {
      _oldTimer = nowUnixTimeSecond();
      _oldPath = path;
      _oldParms = params.toString();
      transition = _getOpenTransitionByNmae(path, transition);
      if (Platform.isAndroid) {
        transition = TransitionType.fadeIn;
      }
      String query = "";
      if (params != null) {
        int index = 0;
        for (var key in params.keys) {
          if (params[key] == null) continue;
          if (key == 'route') {
            if (Platform.isAndroid) {
              transition = TransitionType.fadeIn;
            }
          } else if (key == 'roomId') {
            if (Platform.isAndroid) {
              transition = TransitionType.fadeIn;
            }
          }
          var value = Uri.encodeComponent(params[key]);
          if (index == 0) {
            query = "?";
          } else {
            query = "$query&";
          }
          query += "$key=$value";
          index++;
        }
      }
      pdebug('我是navigateTo传递的参数：$query');

      path = path + query;
      return router!.navigateTo(
        context,
        path,
        clearStack: clearStack,
        transition: transition,
        replace: replace,
      );
    }
  }
}
