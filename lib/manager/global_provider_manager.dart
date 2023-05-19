/*
* 全局性provider
* 可以在此配置 全局性model
* eg: user.model et.
*
* */
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:bobi_pay_out/manager/addr_mgr.dart';
import 'package:bobi_pay_out/manager/config_mgr.dart';
import 'package:bobi_pay_out/view_model/chukuan_model.dart';
import 'package:bobi_pay_out/view_model/config_model.dart';
import 'package:bobi_pay_out/view_model/dizhi_bagname_model.dart';
import 'package:bobi_pay_out/view_model/dizhi_balance_model.dart';
import 'package:bobi_pay_out/view_model/guiji_model.dart';
import 'package:bobi_pay_out/view_model/transcation_model.dart';
import 'package:bobi_pay_out/view_model/locale_model.dart';
import 'package:bobi_pay_out/view_model/net_status_model.dart';
import 'package:bobi_pay_out/view_model/root_scene_model.dart';
import 'package:bobi_pay_out/view_model/theme_model.dart';
import 'package:bobi_pay_out/view_model/tongji_detail_model.dart';
import 'package:bobi_pay_out/view_model/tongji_model.dart';

import '../view_model/dizhi_model.dart';

List<SingleChildWidget> providers = [
  ...independentServices,
  ...userServices,
];

/// 应用级 独立 model(通过consumer 可以在任意页面获取到)
List<SingleChildWidget> independentServices = [
  ChangeNotifierProvider<ThemeModel>(
    create: (context) => ThemeModel(),
  ),
  ChangeNotifierProvider<LocaleModel>(
    create: (context) => LocaleModel(),
  ),
  ChangeNotifierProvider<NetStatusModel>(
    create: (context) => NetStatusModel(),
  ),
  ChangeNotifierProvider<RootSceneModel>(
    create: (context) => RootSceneModel(),
  ),
];

List<SingleChildWidget> userServices = [
  ChangeNotifierProvider<TongjiModel>(
    create: (context) => TongjiModel(),
  ),
  ChangeNotifierProvider<DiZhiModel>(
    create: (context) => DiZhiModel(),
  ),
  ChangeNotifierProvider<DiZhiBagNameModel>(
    create: (context) => dizhi_bagname_model,
  ),
  ChangeNotifierProvider<DiZhiBalanceModel>(
    create: (context) => dizhi_balance_model,
  ),
  ChangeNotifierProvider<TongjiDetailModel>(
    create: (context) => TongjiDetailModel(),
  ),
  ChangeNotifierProvider<ChuKuanModel>(
    create: (context) => chukuan_model,
  ),
  ChangeNotifierProvider<ConfigModel>(
    create: (context) => configModel,
  ),
  ChangeNotifierProvider<GuiJiModel>(
    create: (context) => GuiJiModel(),
  ),
  ChangeNotifierProvider<TranscationModel>(
    create: (context) => TranscationModel(),
  ),
];
