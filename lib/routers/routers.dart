import 'package:flutter/material.dart';
import 'package:bobi_pay_out/app/root_scene.dart';

final Map<String, Function> routers = {
  '/': (context) => RootScene(),
};

//固定写法  路由统一处理方法
Route? onGenerateRoute(RouteSettings settings) {
  //String? 表示name为可空类型
  final String? name = settings.name;
  //Function? 表示pageContentBuilder为可空类型
  final Function? pageContentBuilder = routers[name];
  if (pageContentBuilder != null) {
    if (settings.arguments != null) {
      final Route route = MaterialPageRoute(
          builder: (context) =>
              pageContentBuilder(context, arguments: settings.arguments));
      return route;
    } else {
      final Route route =
          MaterialPageRoute(builder: (context) => pageContentBuilder(context));
      return route;
    }
  }
  return null;
}
