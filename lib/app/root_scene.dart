import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bobi_pay_out/main.dart';
import 'package:bobi_pay_out/manager/config_mgr.dart';
import 'package:bobi_pay_out/model/constant.dart';
import 'package:bobi_pay_out/pages/chukuan.dart';
import 'package:bobi_pay_out/pages/guiji.dart';
import 'package:bobi_pay_out/pages/transcation.dart';
import 'package:bobi_pay_out/pages/tongji.dart';
import 'package:bobi_pay_out/pages/wode.dart';
import 'package:bobi_pay_out/utils/event_bus.dart';
import 'package:bobi_pay_out/utils/string.dart';
import 'package:bobi_pay_out/view_model/root_scene_model.dart';

class RootScene extends StatefulWidget {
  static List<Widget?> pages = [];
  static RootScene? _rootScene;
  static RootSceneState? _rootSceneState;

  /// 实例
  static RootScene? get instance {
    return _rootScene;
  }

  RootSceneState? get rootSceneState {
    return _rootSceneState!;
  }

  RootScene({Key? key}) : super(key: key) {
    _rootScene = this;
  }

  @override
  // ignore: no_logic_in_create_state
  State<StatefulWidget> createState() {
    pages = [];
    _rootSceneState = RootSceneState();
    return _rootSceneState!;
  }
}

class RootSceneState extends State<RootScene> with TickerProviderStateMixin {
  RootSceneModel? _rootSceneModel;

  final _pageController = PageController();
  final List<String> _tabStrArr = ["记录", "出款", "归集", "统计", "我的"];
  final List _tabImages = [
    "icon_jl",
    "icon_ck",
    "icon_gj",
    "icon_tj",
    "icon_wd"
  ];

  getTabIcon(String str) {
    return Image.asset('assets/image/nav/$str.png', width: 24, height: 24);
  }

  @override
  void dispose() {
    eventBus.off(EventEnums.resumed, _onResumed);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    //app回到前台
    eventBus.on(EventEnums.resumed, _onResumed);
    //主场景model
    _rootSceneModel = Provider.of<RootSceneModel>(context, listen: false);
    eventBus.on(EventEnums.showGoogleDialog, (arg) {
      if (confMgr.google_key.isEmpty) {
        Future.delayed(Duration.zero, () {
          showGoogleDialog(context, mounted);
        });
      }
    });
  }

  //后台切换回来 默认检测一次版本更新
  _onResumed(ary) {}

  late List<BottomNavigationBarItem> _items;
  _widgetItems() {
    _items = [];
    RootScene.pages = [];

    RootScene.pages.add(const TranscationPage());
    RootScene.pages.add(const ChuKuanPage());
    RootScene.pages.add(const GuiJiPage());
    RootScene.pages.add(const TongJiPage());
    RootScene.pages.add(const WoDePage());

    Future.delayed(const Duration(milliseconds: 200), () {
      _rootSceneModel!.currentPage =
          RootScenePage.values[_rootSceneModel!.currentPage.index];
      _pageController.jumpToPage(_rootSceneModel!.currentPage.index);
    });

    for (int i = 0; i < _tabStrArr.length; i++) {
      _items.add(BottomNavigationBarItem(
          icon: getTabIcon(_tabImages[i]),
          label: _tabStrArr[i],
          backgroundColor: Colors.grey,
          activeIcon: getTabIcon("${_tabImages[i]}_active")));
    }
  }

  Widget? _widget;
  @override
  Widget build(BuildContext context) {
    if (_widget == null) {
      _widgetItems();
      _widget = WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: Scaffold(
            resizeToAvoidBottomInset: false,
            bottomNavigationBar: Selector<RootSceneModel, RootScenePage>(
              builder: (_, data, __) {
                return BottomNavigationBar(
                  key: UniqueKey(),
                  backgroundColor: mainColor,
                  items: _items,
                  currentIndex: data.index >= _items.length
                      ? _items.length - 1
                      : data.index,
                  onTap: onPageChanged,
                  type: BottomNavigationBarType.fixed,
                  iconSize: 24,
                  selectedItemColor: Colors.white,
                  unselectedItemColor: const Color(0xffDADADA),
                  showUnselectedLabels: true,
                );
              },
              selector: (_, model) => model.currentPage,
            ),
            body: PageView(
                key: UniqueKey(),
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(), // 禁止滑动
                allowImplicitScrolling: true,
                children: List<Widget>.from(RootScene.pages))),
      );
    }
    return _widget!;
  }

  void onPageChanged(int index) {
    _rootSceneModel!.currentPage = RootScenePage.values[index];
    if (mounted) {
      setState(() {
        _pageController.jumpToPage(index);
      });
    }
  }
}
