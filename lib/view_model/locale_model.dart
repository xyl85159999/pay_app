import 'package:flutter/material.dart';

class LocaleModel extends ChangeNotifier {
//  static const localeNameList = ['auto', '中文', 'English'];
  ///Platform.localeName
  ///有些手机 简体中文是 zh_Hans_CN 繁体是 zh_Hant_TW
  ///有些手机 中文简体是 zh_CN 繁体是 zh_TW
  //static const localeValueList = ['', 'zh-CH', 'en-US',"tw-CH"];
  static const localeValueList = ['', 'zh_CN', 'zh_TW'];

  //

  int _localeIndex = 2;

  int get localeIndex => _localeIndex;

  Locale? get locale {
    //初始化放在全局， 放在下面会导致每次刷新index 并且导致国际化切换失败
    if (_localeIndex > 0) {
      var value = localeValueList[_localeIndex].split("_");
      return Locale(value[0], value.length == 2 ? value[1] : '');
    }
    // 跟随系统
    return null;
  }

  switchLocale(int index) {
    _localeIndex = index;
    notifyListeners();
  }

  static String localeName(index, context) {
    switch (index) {
      case 0:
        return "跟随系统";
      case 1:
        return "简体中文";
      case 2:
        return "繁体中文";
      default:
        return '';
    }
  }
}
