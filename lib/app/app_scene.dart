import 'dart:async';

// import 'package:bot_toast/bot_toast.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:bobi_pay_out/manager/connectivity_mgr.dart';
import 'package:bobi_pay_out/manager/global_provider_manager.dart';
import 'package:bobi_pay_out/utils/debug_info.dart';
import 'package:bobi_pay_out/utils/route/routers.dart';
import 'package:bobi_pay_out/view_model/locale_model.dart';
import 'package:bobi_pay_out/view_model/theme_model.dart';

import '../utils/event_bus.dart';
import '../utils/string.dart';

// ignore: use_key_in_widget_constructors
class AppScene extends StatefulWidget {
  @override
  State<AppScene> createState() => _AppSceneState();
}

class _AppSceneState extends State<AppScene> with WidgetsBindingObserver {
  String initPage = Routes.rootScene;
  bool showInitPage = false;

  Future<bool> init(context) async {
    return true;
  }

  @override
  void initState() {
    //监听网络变化
    connectivityMgr.initConnectivityMgr();
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.inactive: // 暂停
        mypdebug('AppLifecycleState.inactive');
        break;
      case AppLifecycleState.resumed: // 前台
        mypdebug('AppLifecycleState.resumed');
        //进来角标直接给0
        eventBus.emit(EventEnums.resumed);
        break;
      case AppLifecycleState.paused: // 后台
        mypdebug('AppLifecycleState.paused');
        eventBus.emit(EventEnums.paused);
        break;
      case AppLifecycleState.detached: // APP结束时调用
        mypdebug('AppLifecycleState.detached');
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
    connectivityMgr.dispose();
  }

  view() {
    return FutureBuilder(
        future: init(context),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              break;
            case ConnectionState.waiting:
              return Container();
            case ConnectionState.active:
              break;
            case ConnectionState.done:
              return view2;
          }
          return Container();
        });
  }

  Widget get view2 {
    showInitPage = true;
    return MultiProvider(
        providers: providers,
        child: Consumer2<ThemeModel, LocaleModel>(
          builder: (context, themeModel, localeModel, child) {
            return RefreshConfiguration(
              hideFooterWhenNotFull: true, //列表数据不满一页,不触发加载更多
              child: MaterialApp(
                localizationsDelegates: const [
                  // delegate from flutter_localization
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                  RefreshLocalizations.delegate,
                  // delegate from localization package.
                ],
                supportedLocales: const [
                  Locale('en', 'US'), // 美国英语
                  Locale('zh', 'CN'), // 中文简体
                  //其它Locales
                ],
                navigatorObservers: [
                  NavigatorObserver(),
                ],
                theme: themeModel.themeData(),
                debugShowCheckedModeBanner: false,
                darkTheme: themeModel.themeData(),
                locale: localeModel.locale, //暂时全部设定为跟随系统
                navigatorKey: GlobalKey<NavigatorState>(),
                onGenerateRoute: Routes.router!.generator,
                initialRoute: initPage,
                builder: (context, widget) {
                  return MediaQuery(
                    ///设置文字大小不随系统设置改变
                    data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                    child: widget!,
                  );
                },
              ),
            );
          },
        ));
  }

  @override
  Widget build(BuildContext context) {
    var router = FluroRouter();
    Routes.configureRoutes(router);
    Routes.router = router;

    return ScreenUtilInit(
      designSize: const Size(360, 690),
      splitScreenMode: false,
      builder: (context, w) => GetMaterialApp(
        home: view2,
      ),
    );
  }
}
